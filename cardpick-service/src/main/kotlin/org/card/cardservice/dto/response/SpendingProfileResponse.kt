package org.card.cardservice.dto.response

import org.card.cardservice.domain.spending.SpendingProfile

data class SpendingProfileResponse(
    val items: List<SpendingItem>,
) {
    data class SpendingItem(
        val id: Long,
        val category: String,
        val monthlyAmount: Int,
    )

    companion object {
        fun from(profiles: List<SpendingProfile>): SpendingProfileResponse =
            SpendingProfileResponse(
                items = profiles.map {
                    SpendingItem(
                        id = it.id,
                        category = it.category,
                        monthlyAmount = it.monthlyAmount,
                    )
                }
            )
    }
}
