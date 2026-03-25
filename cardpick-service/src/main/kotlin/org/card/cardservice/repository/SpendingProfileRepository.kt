package org.card.cardservice.repository

import org.card.cardservice.domain.spending.SpendingProfile
import org.springframework.data.jpa.repository.JpaRepository

interface SpendingProfileRepository : JpaRepository<SpendingProfile, Long> {
    fun findByUserId(userId: Long): List<SpendingProfile>
    fun deleteByUserId(userId: Long)
}
