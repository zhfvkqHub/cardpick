package org.card.cardservice.service

import org.card.cardservice.domain.spending.SpendingProfile
import org.card.cardservice.dto.request.SpendingProfileRequest
import org.card.cardservice.dto.response.SpendingProfileResponse
import org.card.cardservice.repository.SpendingProfileRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class SpendingProfileService(
    private val spendingProfileRepository: SpendingProfileRepository,
) {
    fun getProfiles(userId: Long): SpendingProfileResponse {
        val profiles = spendingProfileRepository.findByUserId(userId)
        return SpendingProfileResponse.from(profiles)
    }

    @Transactional
    fun saveProfiles(userId: Long, request: SpendingProfileRequest): SpendingProfileResponse {
        spendingProfileRepository.deleteByUserId(userId)

        val profiles = request.items.map { item ->
            SpendingProfile(
                userId = userId,
                category = item.category,
                monthlyAmount = item.monthlyAmount,
            )
        }
        val saved = spendingProfileRepository.saveAll(profiles)
        return SpendingProfileResponse.from(saved)
    }

    @Transactional
    fun deleteProfiles(userId: Long) {
        spendingProfileRepository.deleteByUserId(userId)
    }
}
