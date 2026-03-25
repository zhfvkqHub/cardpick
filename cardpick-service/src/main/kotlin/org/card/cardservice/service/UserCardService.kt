package org.card.cardservice.service

import org.card.cardservice.dto.response.CardDetailResponse
import org.card.cardservice.dto.response.CardResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.CardRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class UserCardService(
    private val cardRepository: CardRepository,
) {
    fun getActiveCards(): List<CardResponse> {
        return cardRepository.findByIsActiveTrue().map { CardResponse.from(it) }
    }

    fun getCardDetail(id: Long): CardDetailResponse {
        val card = cardRepository.findById(id)
            .orElseThrow { BusinessException(ErrorCode.CARD_NOT_FOUND) }

        if (!card.isActive) {
            throw BusinessException(ErrorCode.CARD_NOT_FOUND)
        }

        return CardDetailResponse.from(card)
    }
}
