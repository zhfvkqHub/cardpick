package org.card.cardservice.repository

import org.card.cardservice.domain.admin.Admin
import org.springframework.data.jpa.repository.JpaRepository

interface AdminRepository : JpaRepository<Admin, Long> {
    fun findByLoginId(loginId: String): Admin?
}
