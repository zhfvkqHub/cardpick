package org.card.cardservice.domain.recommendation

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "recommendations")
class Recommendation(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "user_id", nullable = false)
    val userId: Long,

    @Column(name = "card_id", nullable = false)
    val cardId: Long,

    @Column(name = "card_name", nullable = false)
    val cardName: String,

    @Column(name = "card_company", nullable = false)
    val cardCompany: String,

    @Column(name = "card_type", nullable = false)
    val cardType: String,

    @Column(name = "annual_fee", nullable = false)
    val annualFee: Int,

    @Column(name = "total_saving", nullable = false, precision = 10, scale = 2)
    val totalSaving: BigDecimal,

    @Column(name = "net_saving", nullable = false, precision = 10, scale = 2)
    val netSaving: BigDecimal,

    @Column(nullable = false)
    val rank: Int,

    @Column(name = "request_id", nullable = false)
    val requestId: String,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),
)
