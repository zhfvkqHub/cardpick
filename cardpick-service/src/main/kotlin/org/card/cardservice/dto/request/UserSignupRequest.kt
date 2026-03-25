package org.card.cardservice.dto.request

import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.Size

data class UserSignupRequest(
    @field:NotBlank(message = "이메일은 필수입니다")
    @field:Email(message = "올바른 이메일 형식이 아닙니다")
    val email: String,

    @field:NotBlank(message = "닉네임은 필수입니다")
    @field:Size(min = 2, max = 20, message = "닉네임은 2~20자여야 합니다")
    val nickname: String,

    @field:NotBlank(message = "비밀번호는 필수입니다")
    @field:Size(min = 8, message = "비밀번호는 8자 이상이어야 합니다")
    val password: String,
)
