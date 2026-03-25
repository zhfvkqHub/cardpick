package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.CardDetailResponse
import org.card.cardservice.dto.response.CardResponse
import org.card.cardservice.service.UserCardService
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "카드 조회", description = "카드 목록/상세 조회 API (공개)")
@RestController
@RequestMapping("/api/v1/cards")
class UserCardController(
    private val userCardService: UserCardService,
) {
    @Operation(summary = "활성 카드 목록 조회")
    @GetMapping
    fun getActiveCards(): ApiResponse<List<CardResponse>> {
        return ApiResponse.ok(userCardService.getActiveCards())
    }

    @Operation(summary = "카드 상세 조회 (혜택 포함)")
    @GetMapping("/{id}")
    fun getCardDetail(@PathVariable id: Long): ApiResponse<CardDetailResponse> {
        return ApiResponse.ok(userCardService.getCardDetail(id))
    }
}
