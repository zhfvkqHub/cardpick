package org.card.cardservice.dto.response

data class TokenResponse(
    val accessToken: String,
    val tokenType: String = "Bearer",
)
