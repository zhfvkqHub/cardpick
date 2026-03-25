package org.card.cardservice.dto.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.PositiveOrZero

data class CardCreateRequest(
    @field:NotBlank(message = "카드사는 필수입니다")
    val cardCompany: String,

    @field:NotBlank(message = "카드명은 필수입니다")
    val cardName: String,

    @field:PositiveOrZero(message = "연회비는 0 이상이어야 합니다")
    val annualFee: Int,

    val minimumSpending: Int? = null,

    @field:NotBlank(message = "카드 유형은 필수입니다")
    val cardType: String,

    val imageUrl: String? = null,
    val description: String? = null,
)
