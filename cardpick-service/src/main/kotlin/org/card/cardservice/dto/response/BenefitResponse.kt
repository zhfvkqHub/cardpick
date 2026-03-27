package org.card.cardservice.dto.response

import org.card.cardservice.domain.card.CardBenefit
import org.card.cardservice.domain.category.Category
import org.card.cardservice.domain.category.CategoryGroup
import java.math.BigDecimal

data class BenefitResponse(
    val id: Long,
    val categoryGroup: String,
    val categoryGroupDisplayName: String,
    val category: String?,
    val categoryDisplayName: String?,
    val benefitType: String,
    val benefitRate: BigDecimal,
    val benefitLimit: Int?,
    val minimumAmount: Int?,
    val description: String?,
) {
    companion object {
        fun from(benefit: CardBenefit): BenefitResponse {
            val group = CategoryGroup.fromCode(benefit.categoryGroup)
            val category = benefit.category?.let { Category.fromCode(it) }
            return BenefitResponse(
                id = benefit.id,
                categoryGroup = benefit.categoryGroup,
                categoryGroupDisplayName = group?.displayName ?: benefit.categoryGroup,
                category = benefit.category,
                categoryDisplayName = category?.displayName,
                benefitType = benefit.benefitType,
                benefitRate = benefit.benefitRate,
                benefitLimit = benefit.benefitLimit,
                minimumAmount = benefit.minimumAmount,
                description = benefit.description,
            )
        }
    }
}
