package org.card.cardservice.domain.card

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.LocalDateTime

@Entity
@Table(name = "pending_cards")
class PendingCard(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "card_company", nullable = false)
    var cardCompany: String,

    @Column(name = "card_name", nullable = false)
    var cardName: String,

    @Column(name = "annual_fee", nullable = false)
    var annualFee: Int,

    @Column(name = "card_type", nullable = false)
    var cardType: String,

    @Column(name = "image_url")
    var imageUrl: String? = null,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,

    @Column(nullable = false)
    var source: String,

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    var status: PendingStatus = PendingStatus.PENDING,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "processed_at")
    var processedAt: LocalDateTime? = null,
)
