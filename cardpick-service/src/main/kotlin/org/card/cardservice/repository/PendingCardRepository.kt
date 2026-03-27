package org.card.cardservice.repository

import org.card.cardservice.domain.card.PendingCard
import org.card.cardservice.domain.card.PendingStatus
import org.springframework.data.jpa.repository.JpaRepository

interface PendingCardRepository : JpaRepository<PendingCard, Long> {
    fun findByStatus(status: PendingStatus): List<PendingCard>
    fun findByCardNameAndCardCompany(cardName: String, cardCompany: String): PendingCard?
    fun countByStatus(status: PendingStatus): Long
}
