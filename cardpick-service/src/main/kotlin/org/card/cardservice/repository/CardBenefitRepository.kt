package org.card.cardservice.repository

import org.card.cardservice.domain.card.CardBenefit
import org.springframework.data.jpa.repository.JpaRepository

interface CardBenefitRepository : JpaRepository<CardBenefit, Long>
