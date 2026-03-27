package org.card.cardservice.domain.card

import jakarta.persistence.*
import java.math.BigDecimal

@Entity
@Table(name = "card_benefits")
class CardBenefit(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "card_id", nullable = false)
    var card: Card,

    @Column(name = "category_group", nullable = false)
    var categoryGroup: String,

    @Column
    var category: String? = null,

    @Column(name = "benefit_type", nullable = false)
    var benefitType: String,

    @Column(name = "benefit_rate", nullable = false, precision = 5, scale = 2)
    var benefitRate: BigDecimal,

    @Column(name = "benefit_limit")
    var benefitLimit: Int? = null,

    @Column(name = "minimum_amount")
    var minimumAmount: Int? = null,

    @Column(columnDefinition = "TEXT")
    var description: String? = null,
)
