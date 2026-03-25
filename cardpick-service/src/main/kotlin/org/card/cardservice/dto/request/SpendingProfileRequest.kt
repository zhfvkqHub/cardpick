package org.card.cardservice.dto.request

import jakarta.validation.Valid
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Positive

data class SpendingProfileRequest(
    @field:NotEmpty(message = "소비 프로필 항목은 최소 1개 이상이어야 합니다")
    @field:Valid
    val items: List<SpendingItem>,
) {
    data class SpendingItem(
        @field:NotBlank(message = "카테고리는 필수입니다")
        val category: String,

        @field:Positive(message = "월 소비 금액은 0보다 커야 합니다")
        val monthlyAmount: Int,
    )
}
