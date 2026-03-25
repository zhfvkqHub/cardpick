package org.card.cardservice.repository

import org.card.cardservice.domain.card.Card
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query

interface CardRepository : JpaRepository<Card, Long> {
    fun findByCardNameAndCardCompany(cardName: String, cardCompany: String): Card?
    fun findByCardNameContainingOrCardCompanyContaining(cardName: String, cardCompany: String): List<Card>
    fun findByIsActiveTrue(): List<Card>

    @Query("SELECT DISTINCT c FROM Card c LEFT JOIN FETCH c.benefits WHERE c.isActive = true")
    fun findActiveCardsWithBenefits(): List<Card>
}
