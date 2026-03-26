package org.card.cardservice.dto.response

import com.fasterxml.jackson.annotation.JsonProperty
import org.card.cardservice.domain.card.Card
import java.time.LocalDateTime

data class CardResponse(
    val id: Long,
    val cardCompany: String,
    val cardName: String,
    val annualFee: Int,
    val minimumSpending: Int?,
    val cardType: String,
    val imageUrl: String?,
    val description: String?,
    @get:JsonProperty("isActive") val isActive: Boolean,
    val benefitCount: Int,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
) {
    companion object {
        fun from(card: Card): CardResponse = CardResponse(
            id = card.id,
            cardCompany = card.cardCompany,
            cardName = card.cardName,
            annualFee = card.annualFee,
            minimumSpending = card.minimumSpending,
            cardType = card.cardType,
            imageUrl = card.imageUrl,
            description = card.description,
            isActive = card.isActive,
            benefitCount = card.benefits.size,
            createdAt = card.createdAt,
            updatedAt = card.updatedAt,
        )
    }
}
