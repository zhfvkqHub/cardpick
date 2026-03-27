package org.card.cardservice.dto.response

import org.card.cardservice.domain.category.Category
import org.card.cardservice.domain.category.CategoryGroup
import org.card.cardservice.domain.spending.SpendingProfile

data class SpendingProfileResponse(
    val items: List<SpendingItem>,
) {
    data class SpendingItem(
        val id: Long,
        val categoryGroup: String,
        val categoryGroupDisplayName: String,
        val category: String?,
        val categoryDisplayName: String?,
        val monthlyAmount: Int,
    )

    companion object {
        fun from(profiles: List<SpendingProfile>): SpendingProfileResponse =
            SpendingProfileResponse(
                items = profiles.map {
                    val group = CategoryGroup.fromCode(it.categoryGroup)
                    val category = it.category?.let { c -> Category.fromCode(c) }
                    SpendingItem(
                        id = it.id,
                        categoryGroup = it.categoryGroup,
                        categoryGroupDisplayName = group?.displayName ?: it.categoryGroup,
                        category = it.category,
                        categoryDisplayName = category?.displayName,
                        monthlyAmount = it.monthlyAmount,
                    )
                }
            )
    }
}
