package org.card.cardservice.service

import org.card.cardservice.domain.category.Category
import org.card.cardservice.domain.category.CategoryGroup
import org.card.cardservice.domain.spending.SpendingProfile
import org.card.cardservice.dto.request.SpendingProfileRequest
import org.card.cardservice.dto.response.SpendingProfileResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
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
        request.items.forEach { item ->
            validateCategory(item.categoryGroup, item.category)
        }

        spendingProfileRepository.deleteByUserId(userId)

        val profiles = request.items.map { item ->
            SpendingProfile(
                userId = userId,
                categoryGroup = item.categoryGroup,
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

    private fun validateCategory(categoryGroupCode: String, categoryCode: String?) {
        val group = CategoryGroup.fromCode(categoryGroupCode)
            ?: throw BusinessException(ErrorCode.INVALID_CATEGORY)
        if (!categoryCode.isNullOrBlank()) {
            val category = Category.fromCode(categoryCode)
                ?: throw BusinessException(ErrorCode.INVALID_CATEGORY)
            if (category.group != group) {
                throw BusinessException(ErrorCode.INVALID_CATEGORY)
            }
        }
    }
}
