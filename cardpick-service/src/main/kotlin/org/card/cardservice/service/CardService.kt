package org.card.cardservice.service

import org.card.cardservice.domain.card.Card
import org.card.cardservice.domain.card.CardBenefit
import org.card.cardservice.domain.category.Category
import org.card.cardservice.domain.category.CategoryGroup
import org.card.cardservice.dto.request.BenefitCreateRequest
import org.card.cardservice.dto.request.BenefitUpdateRequest
import org.card.cardservice.dto.request.CardCreateRequest
import org.card.cardservice.dto.request.CardImportRequest
import org.card.cardservice.dto.request.CardUpdateRequest
import org.card.cardservice.dto.response.BenefitResponse
import org.card.cardservice.dto.response.CardDetailResponse
import org.card.cardservice.dto.response.CardImportFailure
import org.card.cardservice.dto.response.CardImportResult
import org.card.cardservice.dto.response.CardResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.CardBenefitRepository
import org.card.cardservice.repository.CardRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class CardService(
    private val cardRepository: CardRepository,
    private val cardBenefitRepository: CardBenefitRepository,
) {
    /**
     * 카드 목록을 조회합니다.
     *
     * @param keyword 카드명 또는 카드사 검색어. null 또는 공백이면 전체 반환
     */
    fun getCards(keyword: String?): List<CardResponse> {
        val cards = if (keyword.isNullOrBlank()) {
            cardRepository.findAll()
        } else {
            cardRepository.findByCardNameContainingOrCardCompanyContaining(keyword, keyword)
        }
        return cards.map { CardResponse.from(it) }
    }

    /** @throws BusinessException [ErrorCode.CARD_NOT_FOUND] */
    fun getCard(id: Long): CardDetailResponse {
        val card = findCardById(id)
        return CardDetailResponse.from(card)
    }

    /**
     * 카드를 등록합니다.
     *
     * @throws BusinessException [ErrorCode.DUPLICATE_CARD] - 동일한 카드사+카드명이 이미 존재하는 경우
     */
    @Transactional
    fun createCard(request: CardCreateRequest): CardResponse {
        val existing = cardRepository.findByCardNameAndCardCompany(request.cardName, request.cardCompany)
        if (existing != null) {
            throw BusinessException(ErrorCode.DUPLICATE_CARD)
        }

        val card = Card(
            cardCompany = request.cardCompany,
            cardName = request.cardName,
            annualFee = request.annualFee,
            minimumSpending = request.minimumSpending,
            cardType = request.cardType,
            imageUrl = request.imageUrl,
            description = request.description,
        )
        return CardResponse.from(cardRepository.save(card))
    }

    /** @throws BusinessException [ErrorCode.CARD_NOT_FOUND] */
    @Transactional
    fun updateCard(id: Long, request: CardUpdateRequest): CardResponse {
        val card = findCardById(id)
        card.cardCompany = request.cardCompany
        card.cardName = request.cardName
        card.annualFee = request.annualFee
        card.minimumSpending = request.minimumSpending
        card.cardType = request.cardType
        card.imageUrl = request.imageUrl
        card.description = request.description
        card.isActive = request.isActive
        return CardResponse.from(cardRepository.save(card))
    }

    /** @throws BusinessException [ErrorCode.CARD_NOT_FOUND] */
    @Transactional
    fun deleteCard(id: Long) {
        val card = findCardById(id)
        cardRepository.delete(card)
    }

    /**
     * @throws BusinessException [ErrorCode.CARD_NOT_FOUND]
     * @throws BusinessException [ErrorCode.INVALID_CATEGORY]
     */
    @Transactional
    fun createBenefit(cardId: Long, request: BenefitCreateRequest): BenefitResponse {
        val card = findCardById(cardId)
        validateCategory(request.categoryGroup, request.category)
        val benefit = CardBenefit(
            card = card,
            categoryGroup = request.categoryGroup,
            category = request.category,
            benefitType = request.benefitType,
            benefitRate = request.benefitRate,
            benefitLimit = request.benefitLimit,
            minimumAmount = request.minimumAmount,
            description = request.description,
        )
        return BenefitResponse.from(cardBenefitRepository.save(benefit))
    }

    /**
     * @throws BusinessException [ErrorCode.BENEFIT_NOT_FOUND]
     * @throws BusinessException [ErrorCode.INVALID_CATEGORY]
     */
    @Transactional
    fun updateBenefit(benefitId: Long, request: BenefitUpdateRequest): BenefitResponse {
        val benefit = findBenefitById(benefitId)
        validateCategory(request.categoryGroup, request.category)
        benefit.categoryGroup = request.categoryGroup
        benefit.category = request.category
        benefit.benefitType = request.benefitType
        benefit.benefitRate = request.benefitRate
        benefit.benefitLimit = request.benefitLimit
        benefit.minimumAmount = request.minimumAmount
        benefit.description = request.description
        return BenefitResponse.from(cardBenefitRepository.save(benefit))
    }

    /** @throws BusinessException [ErrorCode.CARD_NOT_FOUND] */
    @Transactional
    fun cloneCard(id: Long): CardResponse {
        val original = findCardById(id)
        val cloned = Card(
            cardCompany = original.cardCompany,
            cardName = "${original.cardName} (복사)",
            annualFee = original.annualFee,
            minimumSpending = original.minimumSpending,
            cardType = original.cardType,
            imageUrl = original.imageUrl,
            description = original.description,
        )
        val savedCard = cardRepository.save(cloned)
        original.benefits.forEach { benefit ->
            cardBenefitRepository.save(
                CardBenefit(
                    card = savedCard,
                    categoryGroup = benefit.categoryGroup,
                    category = benefit.category,
                    benefitType = benefit.benefitType,
                    benefitRate = benefit.benefitRate,
                    benefitLimit = benefit.benefitLimit,
                    minimumAmount = benefit.minimumAmount,
                    description = benefit.description,
                ),
            )
        }
        return CardResponse.from(cardRepository.findById(savedCard.id).get())
    }

    @Transactional
    fun importCards(request: CardImportRequest): CardImportResult {
        val failed = mutableListOf<CardImportFailure>()
        var successCount = 0

        for (item in request.cards) {
            try {
                if (item.cardCompany.isBlank() || item.cardName.isBlank() || item.cardType.isBlank()) {
                    failed.add(CardImportFailure(item.cardName.ifBlank { "(이름 없음)" }, "필수 항목이 누락됐습니다"))
                    continue
                }
                if (cardRepository.findByCardNameAndCardCompany(item.cardName, item.cardCompany) != null) {
                    failed.add(CardImportFailure(item.cardName, "이미 등록된 카드입니다"))
                    continue
                }
                item.benefits.forEach { b -> validateCategory(b.categoryGroup, b.category) }

                val card = Card(
                    cardCompany = item.cardCompany,
                    cardName = item.cardName,
                    annualFee = item.annualFee,
                    minimumSpending = item.minimumSpending,
                    cardType = item.cardType,
                    imageUrl = item.imageUrl,
                    description = item.description,
                )
                val savedCard = cardRepository.save(card)
                item.benefits.forEach { b ->
                    cardBenefitRepository.save(
                        CardBenefit(
                            card = savedCard,
                            categoryGroup = b.categoryGroup,
                            category = b.category,
                            benefitType = b.benefitType,
                            benefitRate = b.benefitRate,
                            benefitLimit = b.benefitLimit,
                            minimumAmount = b.minimumAmount,
                            description = b.description,
                        ),
                    )
                }
                successCount++
            } catch (e: BusinessException) {
                failed.add(CardImportFailure(item.cardName.ifBlank { "(이름 없음)" }, e.errorCode.message))
            } catch (e: Exception) {
                failed.add(CardImportFailure(item.cardName.ifBlank { "(이름 없음)" }, "처리 중 오류가 발생했습니다"))
            }
        }
        return CardImportResult(successCount, failed.size, failed)
    }

    /** @throws BusinessException [ErrorCode.BENEFIT_NOT_FOUND] */
    @Transactional
    fun deleteBenefit(benefitId: Long) {
        val benefit = findBenefitById(benefitId)
        cardBenefitRepository.delete(benefit)
    }

    private fun findCardById(id: Long): Card {
        return cardRepository.findById(id)
            .orElseThrow { BusinessException(ErrorCode.CARD_NOT_FOUND) }
    }

    private fun findBenefitById(id: Long): CardBenefit {
        return cardBenefitRepository.findById(id)
            .orElseThrow { BusinessException(ErrorCode.BENEFIT_NOT_FOUND) }
    }

    private fun validateCategory(categoryGroupCode: String, categoryCode: String?) {
        val group = CategoryGroup.fromCode(categoryGroupCode)
            ?: throw BusinessException(ErrorCode.INVALID_CATEGORY)
        if (!categoryCode.isNullOrBlank()) {
            val category = Category.fromCode(categoryCode)
                ?: throw BusinessException(ErrorCode.INVALID_CATEGORY)
            if (category.group != group) {
                throw BusinessException(ErrorCode.INVALID_CATEGORY)
            }
        }
    }
}
