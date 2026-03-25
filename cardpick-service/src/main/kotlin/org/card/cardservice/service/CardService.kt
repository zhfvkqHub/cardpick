package org.card.cardservice.service

import org.card.cardservice.domain.card.Card
import org.card.cardservice.domain.card.CardBenefit
import org.card.cardservice.dto.request.BenefitCreateRequest
import org.card.cardservice.dto.request.BenefitUpdateRequest
import org.card.cardservice.dto.request.CardCreateRequest
import org.card.cardservice.dto.request.CardUpdateRequest
import org.card.cardservice.dto.response.BenefitResponse
import org.card.cardservice.dto.response.CardDetailResponse
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

    /** @throws BusinessException [ErrorCode.CARD_NOT_FOUND] */
    @Transactional
    fun createBenefit(cardId: Long, request: BenefitCreateRequest): BenefitResponse {
        val card = findCardById(cardId)
        val benefit = CardBenefit(
            card = card,
            category = request.category,
            benefitType = request.benefitType,
            benefitRate = request.benefitRate,
            benefitLimit = request.benefitLimit,
            minimumAmount = request.minimumAmount,
            description = request.description,
        )
        return BenefitResponse.from(cardBenefitRepository.save(benefit))
    }

    /** @throws BusinessException [ErrorCode.BENEFIT_NOT_FOUND] */
    @Transactional
    fun updateBenefit(benefitId: Long, request: BenefitUpdateRequest): BenefitResponse {
        val benefit = findBenefitById(benefitId)
        benefit.category = request.category
        benefit.benefitType = request.benefitType
        benefit.benefitRate = request.benefitRate
        benefit.benefitLimit = request.benefitLimit
        benefit.minimumAmount = request.minimumAmount
        benefit.description = request.description
        return BenefitResponse.from(cardBenefitRepository.save(benefit))
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
}
