package org.card.cardservice.domain.admin

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "admins")
class Admin(
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        val id: Long = 0,

        @Column(name = "login_id", nullable = false, unique = true)
        val loginId: String,

        @Column(name = "password_hash", nullable = false)
        var passwordHash: String?,

        @Column(nullable = false)
        var name: String,

        @Column(name = "created_at", nullable = false, updatable = false)
        val createdAt: LocalDateTime = LocalDateTime.now(),

        @Column(name = "updated_at", nullable = false)
        var updatedAt: LocalDateTime = LocalDateTime.now(),
) {
    @PreUpdate
    fun onUpdate() {
        updatedAt = LocalDateTime.now()
    }
}
