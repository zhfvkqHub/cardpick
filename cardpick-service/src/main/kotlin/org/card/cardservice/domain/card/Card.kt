package org.card.cardservice.domain.card

import jakarta.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "cards")
class Card(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "card_company", nullable = false)
    var cardCompany: String,

    @Column(name = "card_name", nullable = false)
    var cardName: String,

    @Column(name = "annual_fee", nullable = false)
    var annualFee: Int,

    @Column(name = "minimum_spending")
    var minimumSpending: Int? = null,

    @Column(name = "card_type", nullable = false)
    var cardType: String,

    @Column(name = "image_url")
    var imageUrl: String? = null,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    @Column(name = "is_active", nullable = false)
    var isActive: Boolean = true,

    @OneToMany(mappedBy = "card", cascade = [CascadeType.ALL], orphanRemoval = true)
    val benefits: MutableList<CardBenefit> = mutableListOf(),

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
