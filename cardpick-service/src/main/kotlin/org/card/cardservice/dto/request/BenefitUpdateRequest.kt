package org.card.cardservice.dto.request

import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Positive
import java.math.BigDecimal

data class BenefitUpdateRequest(
    @field:NotBlank(message = "카테고리는 필수입니다")
    val category: String,

    @field:NotBlank(message = "혜택 유형은 필수입니다")
    val benefitType: String,

    @field:Positive(message = "혜택 비율은 0보다 커야 합니다")
    val benefitRate: BigDecimal,

    val benefitLimit: Int? = null,
    val minimumAmount: Int? = null,
    val description: String? = null,
)
