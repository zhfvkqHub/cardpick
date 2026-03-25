package org.card.cardservice.dto.response

import org.card.cardservice.domain.card.CardBenefit
import java.math.BigDecimal

data class BenefitResponse(
    val id: Long,
    val category: String,
    val benefitType: String,
    val benefitRate: BigDecimal,
    val benefitLimit: Int?,
    val minimumAmount: Int?,
    val description: String?,
) {
    companion object {
        fun from(benefit: CardBenefit): BenefitResponse = BenefitResponse(
            id = benefit.id,
            category = benefit.category,
            benefitType = benefit.benefitType,
            benefitRate = benefit.benefitRate,
            benefitLimit = benefit.benefitLimit,
            minimumAmount = benefit.minimumAmount,
            description = benefit.description,
        )
    }
}
