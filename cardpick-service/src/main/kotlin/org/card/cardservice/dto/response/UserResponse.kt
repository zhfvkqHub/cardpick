package org.card.cardservice.dto.response

import org.card.cardservice.domain.user.User
import java.time.LocalDateTime

data class UserResponse(
    val id: Long,
    val email: String,
    val nickname: String,
    val createdAt: LocalDateTime,
) {
    companion object {
        fun from(user: User): UserResponse = UserResponse(
            id = user.id,
            email = user.email,
            nickname = user.nickname,
            createdAt = user.createdAt,
        )
    }
}
