package org.card.cardservice.domain.spending

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "spending_profiles")
class SpendingProfile(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "user_id", nullable = false)
    val userId: Long,

    @Column(name = "category_group", nullable = false)
    var categoryGroup: String,

    @Column
    var category: String? = null,

    @Column(name = "monthly_amount", nullable = false)
    var monthlyAmount: Int,

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
