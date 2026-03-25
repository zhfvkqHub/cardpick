package org.card.cardservice.repository

import org.card.cardservice.domain.recommendation.Recommendation
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query

interface RecommendationRepository : JpaRepository<Recommendation, Long> {
    fun findByRequestIdOrderByRankAsc(requestId: String): List<Recommendation>

    /**
     * 사용자의 가장 최근 추천 요청 결과 1건을 createdAt 내림차순으로 조회합니다.
     * requestId(UUID 문자열) 기준 MAX 비교 대신 createdAt을 사용해 정확한 최신 항목을 가져옵니다.
     */
    fun findFirstByUserIdOrderByCreatedAtDesc(userId: Long): Recommendation?
}
