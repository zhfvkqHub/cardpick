package org.card.cardservice.config

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component
import java.util.*
import javax.crypto.SecretKey

@Component
class JwtTokenProvider(
    @Value("\${jwt.secret}") private val secret: String,
    @Value("\${jwt.expiration}") private val expirationMs: Long,
) {
    private val key: SecretKey by lazy {
        Keys.hmacShaKeyFor(Base64.getDecoder().decode(secret))
    }

    fun generateToken(id: Long, identifier: String, role: String): String {
        val now = Date()
        val expiry = Date(now.time + expirationMs)

        return Jwts.builder()
            .subject(id.toString())
            .claim("identifier", identifier)
            .claim("role", role)
            .issuedAt(now)
            .expiration(expiry)
            .signWith(key)
            .compact()
    }

    fun getIdFromToken(token: String): Long {
        return getClaims(token).subject.toLong()
    }

    fun getRoleFromToken(token: String): String {
        return getClaims(token)["role"] as String
    }

    fun validateToken(token: String): Boolean {
        return try {
            getClaims(token)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun getClaims(token: String): Claims {
        return Jwts.parser()
            .verifyWith(key)
            .build()
            .parseSignedClaims(token)
            .payload
    }
}
