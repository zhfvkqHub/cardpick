package org.card.cardservice.dto.response

import org.card.cardservice.domain.recommendation.Recommendation
import java.math.BigDecimal
import java.time.LocalDateTime

data class RecommendationResponse(
    val requestId: String,
    val createdAt: LocalDateTime?,
    val cards: List<RecommendedCard>,
) {
    data class RecommendedCard(
        val rank: Int,
        val cardId: Long,
        val cardName: String,
        val cardCompany: String,
        val cardType: String,
        val annualFee: Int,
        val totalSaving: BigDecimal,
        val netSaving: BigDecimal,
    )

    companion object {
        fun from(recommendations: List<Recommendation>): RecommendationResponse {
            if (recommendations.isEmpty()) {
                return RecommendationResponse(requestId = "", createdAt = null, cards = emptyList())
            }
            return RecommendationResponse(
                requestId = recommendations.first().requestId,
                createdAt = recommendations.first().createdAt,
                cards = recommendations.map {
                    RecommendedCard(
                        rank = it.rank,
                        cardId = it.cardId,
                        cardName = it.cardName,
                        cardCompany = it.cardCompany,
                        cardType = it.cardType,
                        annualFee = it.annualFee,
                        totalSaving = it.totalSaving,
                        netSaving = it.netSaving,
                    )
                }
            )
        }
    }
}
