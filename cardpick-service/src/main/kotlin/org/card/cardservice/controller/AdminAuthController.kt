package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.card.cardservice.dto.request.AdminLoginRequest
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.TokenResponse
import org.card.cardservice.service.AdminAuthService
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "관리자 인증", description = "관리자 로그인 API")
@RestController
@RequestMapping("/api/admin/auth")
class AdminAuthController(
    private val adminAuthService: AdminAuthService,
) {
    @Operation(summary = "관리자 로그인", description = "loginId/password 검증 후 JWT 토큰을 반환합니다")
    @PostMapping("/login")
    fun login(@Valid @RequestBody request: AdminLoginRequest): ApiResponse<TokenResponse> {
        return ApiResponse.ok(adminAuthService.login(request))
    }
}
