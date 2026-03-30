package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import jakarta.validation.constraints.Size
import org.card.cardservice.dto.request.BenefitCreateRequest
import org.card.cardservice.dto.request.BenefitUpdateRequest
import org.card.cardservice.dto.request.CardCreateRequest
import org.card.cardservice.dto.request.CardImportRequest
import org.card.cardservice.dto.request.CardUpdateRequest
import org.card.cardservice.dto.response.*
import org.card.cardservice.service.CardService
import org.springframework.validation.annotation.Validated
import org.springframework.web.bind.annotation.*

@Tag(name = "관리자 카드 관리", description = "카드 및 혜택 CRUD API (관리자 전용)")
@Validated
@RestController
@RequestMapping("/api/admin/cards")
class AdminCardController(
    private val cardService: CardService,
) {
    @Operation(summary = "카드 목록 조회", description = "keyword로 카드명 또는 카드사를 검색합니다 (최대 100자)")
    @GetMapping
    fun getCards(
        @RequestParam(required = false)
        @Size(max = 100, message = "검색어는 100자 이하여야 합니다")
        keyword: String?,
    ): ApiResponse<List<CardResponse>> {
        return ApiResponse.ok(cardService.getCards(keyword))
    }

    @Operation(summary = "카드 상세 조회", description = "카드 정보와 혜택 목록을 반환합니다")
    @GetMapping("/{id}")
    fun getCard(@PathVariable id: Long): ApiResponse<CardDetailResponse> {
        return ApiResponse.ok(cardService.getCard(id))
    }

    @Operation(summary = "카드 등록", description = "새 카드를 등록합니다. 동일한 카드사+카드명이 존재하면 409를 반환합니다")
    @PostMapping
    fun createCard(@Valid @RequestBody request: CardCreateRequest): ApiResponse<CardResponse> {
        return ApiResponse.ok(cardService.createCard(request))
    }

    @Operation(summary = "카드 수정", description = "카드 정보를 수정합니다. isActive로 활성/비활성 전환 가능")
    @PutMapping("/{id}")
    fun updateCard(
        @PathVariable id: Long,
        @Valid @RequestBody request: CardUpdateRequest,
    ): ApiResponse<CardResponse> {
        return ApiResponse.ok(cardService.updateCard(id, request))
    }

    @Operation(summary = "카드 삭제", description = "카드를 영구 삭제합니다. 연관된 혜택도 함께 삭제됩니다")
    @DeleteMapping("/{id}")
    fun deleteCard(@PathVariable id: Long): ApiResponse<Unit> {
        cardService.deleteCard(id)
        return ApiResponse.ok()
    }

    @Operation(summary = "카드 복제", description = "카드와 혜택을 복사해 새 카드를 생성합니다. 카드명에 '(복사)'가 붙습니다")
    @PostMapping("/{id}/clone")
    fun cloneCard(@PathVariable id: Long): ApiResponse<CardResponse> {
        return ApiResponse.ok(cardService.cloneCard(id))
    }

    @Operation(summary = "카드 JSON 일괄 임포트", description = "JSON 배열로 카드와 혜택을 일괄 등록합니다. 실패한 항목은 결과에 포함됩니다")
    @PostMapping("/import")
    fun importCards(@Valid @RequestBody request: CardImportRequest): ApiResponse<CardImportResult> {
        return ApiResponse.ok(cardService.importCards(request))
    }

    @Operation(summary = "혜택 추가", description = "카드에 혜택을 추가합니다")
    @PostMapping("/{cardId}/benefits")
    fun createBenefit(
        @PathVariable cardId: Long,
        @Valid @RequestBody request: BenefitCreateRequest,
    ): ApiResponse<BenefitResponse> {
        return ApiResponse.ok(cardService.createBenefit(cardId, request))
    }

    @Operation(summary = "혜택 수정")
    @PutMapping("/benefits/{benefitId}")
    fun updateBenefit(
        @PathVariable benefitId: Long,
        @Valid @RequestBody request: BenefitUpdateRequest,
    ): ApiResponse<BenefitResponse> {
        return ApiResponse.ok(cardService.updateBenefit(benefitId, request))
    }

    @Operation(summary = "혜택 삭제")
    @DeleteMapping("/benefits/{benefitId}")
    fun deleteBenefit(@PathVariable benefitId: Long): ApiResponse<Unit> {
        cardService.deleteBenefit(benefitId)
        return ApiResponse.ok()
    }
}
