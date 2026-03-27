package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.PendingCardResponse
import org.card.cardservice.service.PendingCardService
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "관리자 대기 카드 관리", description = "금융감독원 API로 수집된 대기 카드 승인/반려 API")
@RestController
@RequestMapping("/api/admin/pending-cards")
class AdminPendingCardController(
    private val pendingCardService: PendingCardService,
) {
    @Operation(summary = "대기 카드 목록 조회", description = "PENDING 상태의 카드 목록을 반환합니다")
    @GetMapping
    fun getPendingCards(): ApiResponse<List<PendingCardResponse>> {
        return ApiResponse.ok(pendingCardService.getPendingCards())
    }

    @Operation(summary = "대기 카드 건수 조회", description = "PENDING 상태의 카드 건수를 반환합니다")
    @GetMapping("/count")
    fun getPendingCount(): ApiResponse<Long> {
        return ApiResponse.ok(pendingCardService.getPendingCount())
    }

    @Operation(summary = "대기 카드 승인", description = "대기 카드를 승인하고 Card 테이블에 등록합니다")
    @PostMapping("/{id}/approve")
    fun approvePendingCard(@PathVariable id: Long): ApiResponse<PendingCardResponse> {
        return ApiResponse.ok(pendingCardService.approvePendingCard(id))
    }

    @Operation(summary = "대기 카드 반려", description = "대기 카드를 반려합니다")
    @PostMapping("/{id}/reject")
    fun rejectPendingCard(@PathVariable id: Long): ApiResponse<PendingCardResponse> {
        return ApiResponse.ok(pendingCardService.rejectPendingCard(id))
    }

    @Operation(summary = "수동 수집", description = "금융감독원 API를 즉시 호출하여 카드를 수집합니다")
    @PostMapping("/collect")
    fun collectCards(): ApiResponse<Int> {
        return ApiResponse.ok(pendingCardService.collectNow())
    }
}
