package org.card.cardservice.service

import org.card.cardservice.domain.card.Card
import org.card.cardservice.domain.card.PendingStatus
import org.card.cardservice.dto.response.PendingCardResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.CardRepository
import org.card.cardservice.repository.PendingCardRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.LocalDateTime

@Service
@Transactional(readOnly = true)
class PendingCardService(
    private val pendingCardRepository: PendingCardRepository,
    private val cardRepository: CardRepository,
    private val cardCollectorService: CardCollectorService,
) {
    fun getPendingCards(): List<PendingCardResponse> {
        return pendingCardRepository.findByStatus(PendingStatus.PENDING)
            .map { PendingCardResponse.from(it) }
    }

    fun getPendingCount(): Long {
        return pendingCardRepository.countByStatus(PendingStatus.PENDING)
    }

    @Transactional
    fun approvePendingCard(id: Long): PendingCardResponse {
        val pendingCard = pendingCardRepository.findById(id)
            .orElseThrow { BusinessException(ErrorCode.PENDING_CARD_NOT_FOUND) }

        if (pendingCard.status != PendingStatus.PENDING) {
            throw BusinessException(ErrorCode.PENDING_CARD_ALREADY_PROCESSED)
        }

        // Card 테이블에 등록
        val card = Card(
            cardCompany = pendingCard.cardCompany,
            cardName = pendingCard.cardName,
            annualFee = pendingCard.annualFee,
            cardType = pendingCard.cardType,
            imageUrl = pendingCard.imageUrl,
            description = pendingCard.description,
        )
        cardRepository.save(card)

        // PendingCard 상태 변경
        pendingCard.status = PendingStatus.APPROVED
        pendingCard.processedAt = LocalDateTime.now()
        pendingCardRepository.save(pendingCard)

        return PendingCardResponse.from(pendingCard)
    }

    @Transactional
    fun rejectPendingCard(id: Long): PendingCardResponse {
        val pendingCard = pendingCardRepository.findById(id)
            .orElseThrow { BusinessException(ErrorCode.PENDING_CARD_NOT_FOUND) }

        if (pendingCard.status != PendingStatus.PENDING) {
            throw BusinessException(ErrorCode.PENDING_CARD_ALREADY_PROCESSED)
        }

        pendingCard.status = PendingStatus.REJECTED
        pendingCard.processedAt = LocalDateTime.now()
        pendingCardRepository.save(pendingCard)

        return PendingCardResponse.from(pendingCard)
    }

    @Transactional
    fun collectNow(): Int {
        return cardCollectorService.collectCards()
    }
}
