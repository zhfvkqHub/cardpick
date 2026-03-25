package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.card.cardservice.dto.request.SpendingProfileRequest
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.SpendingProfileResponse
import org.card.cardservice.service.SpendingProfileService
import org.springframework.security.core.Authentication
import org.springframework.web.bind.annotation.*

@Tag(name = "소비 프로필", description = "소비 프로필 관리 API (인증 필요)")
@RestController
@RequestMapping("/api/v1/spending-profiles")
class SpendingProfileController(
    private val spendingProfileService: SpendingProfileService,
) {
    @Operation(summary = "내 소비 프로필 조회")
    @GetMapping
    fun getProfiles(authentication: Authentication): ApiResponse<SpendingProfileResponse> {
        val userId = authentication.principal as Long
        return ApiResponse.ok(spendingProfileService.getProfiles(userId))
    }

    @Operation(summary = "소비 프로필 등록/수정 (전체 교체)")
    @PutMapping
    fun saveProfiles(
        authentication: Authentication,
        @Valid @RequestBody request: SpendingProfileRequest,
    ): ApiResponse<SpendingProfileResponse> {
        val userId = authentication.principal as Long
        return ApiResponse.ok(spendingProfileService.saveProfiles(userId, request))
    }

    @Operation(summary = "소비 프로필 초기화")
    @DeleteMapping
    fun deleteProfiles(authentication: Authentication): ApiResponse<Unit> {
        val userId = authentication.principal as Long
        spendingProfileService.deleteProfiles(userId)
        return ApiResponse.ok()
    }
}
