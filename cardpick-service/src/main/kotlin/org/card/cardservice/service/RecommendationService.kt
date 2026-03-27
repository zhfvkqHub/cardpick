package org.card.cardservice.service

import org.card.cardservice.domain.recommendation.Recommendation
import org.card.cardservice.dto.response.RecommendationResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.CardRepository
import org.card.cardservice.repository.RecommendationRepository
import org.card.cardservice.repository.SpendingProfileRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal
import java.math.RoundingMode
import java.util.*

@Service
@Transactional(readOnly = true)
class RecommendationService(
    private val recommendationRepository: RecommendationRepository,
    private val spendingProfileRepository: SpendingProfileRepository,
    private val cardRepository: CardRepository,
) {
    /**
     * 사용자의 소비 프로필을 기반으로 최적 카드 Top 5를 추천합니다.
     *
     * ## 추천 알고리즘
     * 1. 활성 카드 전체와 사용자 소비 카테고리를 매칭
     * 2. 카테고리별 월 소비금액 × 혜택율(%) = 예상 절감액 계산
     *    - 혜택 한도(benefitLimit)가 있으면 절감액을 한도 이내로 제한
     * 3. 카드 연회비를 월 환산(÷12)하여 순절감액(netSaving) 계산
     * 4. netSaving 내림차순으로 정렬 후 상위 5개 저장
     *
     * @throws BusinessException [ErrorCode.SPENDING_PROFILE_EMPTY] - 소비 프로필 미등록
     * @throws BusinessException [ErrorCode.NO_ACTIVE_CARDS] - 활성 카드 없음
     */
    @Transactional
    fun recommend(userId: Long): RecommendationResponse {
        val profiles = spendingProfileRepository.findByUserId(userId)
        if (profiles.isEmpty()) {
            throw BusinessException(ErrorCode.SPENDING_PROFILE_EMPTY)
        }

        val cards = cardRepository.findActiveCardsWithBenefits()
        if (cards.isEmpty()) {
            throw BusinessException(ErrorCode.NO_ACTIVE_CARDS)
        }

        val requestId = UUID.randomUUID().toString()

        data class CardScore(
            val cardId: Long,
            val cardName: String,
            val cardCompany: String,
            val annualFee: Int,
            val totalSaving: BigDecimal,
            val netSaving: BigDecimal,
        )

        val scores = cards.map { card ->
            val totalSaving = profiles.sumOf { profile ->
                val matchingBenefits = card.benefits.filter { benefit ->
                    benefit.categoryGroup == profile.categoryGroup &&
                        (benefit.category == null || profile.category == null || benefit.category == profile.category)
                }
                matchingBenefits.sumOf { benefit ->
                    val saving = BigDecimal(profile.monthlyAmount)
                        .multiply(benefit.benefitRate)
                        .divide(BigDecimal(100), 2, RoundingMode.HALF_UP)

                    val limit = benefit.benefitLimit
                    if (limit != null) {
                        saving.min(BigDecimal(limit))
                    } else {
                        saving
                    }
                }
            }

            val monthlyFee = BigDecimal(card.annualFee)
                .divide(BigDecimal(12), 2, RoundingMode.HALF_UP)

            CardScore(
                cardId = card.id,
                cardName = card.cardName,
                cardCompany = card.cardCompany,
                annualFee = card.annualFee,
                totalSaving = totalSaving,
                netSaving = totalSaving.subtract(monthlyFee),
            )
        }

        val top5 = scores
            .sortedByDescending { it.netSaving }
            .take(5)

        val recommendations = top5.mapIndexed { index, score ->
            Recommendation(
                userId = userId,
                cardId = score.cardId,
                cardName = score.cardName,
                cardCompany = score.cardCompany,
                annualFee = score.annualFee,
                totalSaving = score.totalSaving,
                netSaving = score.netSaving,
                rank = index + 1,
                requestId = requestId,
            )
        }

        val saved = recommendationRepository.saveAll(recommendations)
        return RecommendationResponse.from(saved)
    }

    fun getLatest(userId: Long): RecommendationResponse {
        // createdAt 기준으로 가장 최근 항목을 먼저 찾아 requestId를 특정한 뒤,
        // 해당 requestId로 전체 추천 결과를 rank 순으로 조회합니다.
        val latest = recommendationRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
            ?: throw BusinessException(ErrorCode.RECOMMENDATION_NOT_FOUND)
        val recommendations = recommendationRepository.findByRequestIdOrderByRankAsc(latest.requestId)
        return RecommendationResponse.from(recommendations)
    }

    /**
     * requestId에 해당하는 추천 결과를 조회합니다.
     * 결과가 없거나 요청자가 소유자가 아닌 경우 동일한 에러를 반환합니다.
     *
     * @throws BusinessException [ErrorCode.RECOMMENDATION_NOT_FOUND]
     */
    fun getByRequestId(userId: Long, requestId: String): RecommendationResponse {
        val recommendations = recommendationRepository.findByRequestIdOrderByRankAsc(requestId)
        if (recommendations.isEmpty() || recommendations.first().userId != userId) {
            throw BusinessException(ErrorCode.RECOMMENDATION_NOT_FOUND)
        }
        return RecommendationResponse.from(recommendations)
    }
}
