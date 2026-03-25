package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.RecommendationResponse
import org.card.cardservice.service.RecommendationService
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@Tag(name = "카드 추천", description = "카드 추천 API (인증 필요)")
@RestController
@RequestMapping("/api/v1/recommendations")
class RecommendationController(
    private val recommendationService: RecommendationService,
) {
    @Operation(summary = "추천 요청 (계산 + 저장)")
    @PostMapping
    fun recommend(authentication: Authentication): ApiResponse<RecommendationResponse> {
        val userId = authentication.principal as Long
        return ApiResponse.ok(recommendationService.recommend(userId))
    }

    @Operation(summary = "최근 추천 결과 조회")
    @GetMapping("/latest")
    fun getLatest(authentication: Authentication): ApiResponse<RecommendationResponse> {
        val userId = authentication.principal as Long
        return ApiResponse.ok(recommendationService.getLatest(userId))
    }

    @Operation(summary = "추천 상세 조회 (requestId)")
    @GetMapping("/{requestId}")
    fun getByRequestId(
        authentication: Authentication,
        @PathVariable requestId: String,
    ): ApiResponse<RecommendationResponse> {
        val userId = authentication.principal as Long
        return ApiResponse.ok(recommendationService.getByRequestId(userId, requestId))
    }
}
