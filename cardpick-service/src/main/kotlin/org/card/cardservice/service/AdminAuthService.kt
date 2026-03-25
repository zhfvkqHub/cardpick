package org.card.cardservice.service

import org.card.cardservice.config.JwtTokenProvider
import org.card.cardservice.dto.request.AdminLoginRequest
import org.card.cardservice.dto.response.TokenResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.AdminRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class AdminAuthService(
    private val adminRepository: AdminRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    /**
     * 관리자 로그인을 처리합니다.
     *
     * loginId 미존재 또는 비밀번호 불일치 시 동일한 [ErrorCode.INVALID_CREDENTIALS] 에러를 반환하여
     * 계정 존재 여부를 외부에 노출하지 않습니다.
     *
     * @throws BusinessException [ErrorCode.INVALID_CREDENTIALS] - 아이디 또는 비밀번호 오류
     */
    fun login(request: AdminLoginRequest): TokenResponse {
        val admin = adminRepository.findByLoginId(request.loginId)
            ?: throw BusinessException(ErrorCode.INVALID_CREDENTIALS)

        if (!passwordEncoder.matches(request.password, admin.passwordHash)) {
            throw BusinessException(ErrorCode.INVALID_CREDENTIALS)
        }

        val token = jwtTokenProvider.generateToken(admin.id, admin.loginId, "ROLE_ADMIN")
        return TokenResponse(accessToken = token)
    }
}
