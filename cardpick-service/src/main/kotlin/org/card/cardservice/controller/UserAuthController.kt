package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.card.cardservice.dto.request.UserLoginRequest
import org.card.cardservice.dto.request.UserSignupRequest
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.TokenResponse
import org.card.cardservice.dto.response.UserResponse
import org.card.cardservice.service.UserAuthService
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "사용자 인증", description = "회원가입/로그인 API")
@RestController
@RequestMapping("/api/v1/auth")
class UserAuthController(
    private val userAuthService: UserAuthService,
) {
    @Operation(summary = "회원가입")
    @PostMapping("/signup")
    fun signup(@Valid @RequestBody request: UserSignupRequest): ApiResponse<UserResponse> {
        return ApiResponse.ok(userAuthService.signup(request))
    }

    @Operation(summary = "로그인")
    @PostMapping("/login")
    fun login(@Valid @RequestBody request: UserLoginRequest): ApiResponse<TokenResponse> {
        return ApiResponse.ok(userAuthService.login(request))
    }
}
