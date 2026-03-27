package org.card.cardservice.dto.response

import org.card.cardservice.domain.card.PendingCard
import java.time.LocalDateTime

data class PendingCardResponse(
    val id: Long,
    val cardCompany: String,
    val cardName: String,
    val annualFee: Int,
    val cardType: String,
    val imageUrl: String?,
    val description: String?,
    val source: String,
    val status: String,
    val createdAt: LocalDateTime,
    val processedAt: LocalDateTime?,
) {
    companion object {
        fun from(pendingCard: PendingCard): PendingCardResponse = PendingCardResponse(
            id = pendingCard.id,
            cardCompany = pendingCard.cardCompany,
            cardName = pendingCard.cardName,
            annualFee = pendingCard.annualFee,
            cardType = pendingCard.cardType,
            imageUrl = pendingCard.imageUrl,
            description = pendingCard.description,
            source = pendingCard.source,
            status = pendingCard.status.name,
            createdAt = pendingCard.createdAt,
            processedAt = pendingCard.processedAt,
        )
    }
}
