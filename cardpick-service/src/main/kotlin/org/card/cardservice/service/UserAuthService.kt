package org.card.cardservice.service

import org.card.cardservice.config.JwtTokenProvider
import org.card.cardservice.domain.user.User
import org.card.cardservice.dto.request.UserLoginRequest
import org.card.cardservice.dto.request.UserSignupRequest
import org.card.cardservice.dto.response.TokenResponse
import org.card.cardservice.dto.response.UserResponse
import org.card.cardservice.exception.BusinessException
import org.card.cardservice.exception.ErrorCode
import org.card.cardservice.repository.UserRepository
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional(readOnly = true)
class UserAuthService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val jwtTokenProvider: JwtTokenProvider,
) {
    /**
     * 신규 사용자를 등록합니다.
     *
     * @throws BusinessException [ErrorCode.DUPLICATE_EMAIL] - 이미 사용 중인 이메일
     */
    @Transactional
    fun signup(request: UserSignupRequest): UserResponse {
        if (userRepository.existsByEmail(request.email)) {
            throw BusinessException(ErrorCode.DUPLICATE_EMAIL)
        }

        val user = User(
            email = request.email,
            nickname = request.nickname,
            passwordHash = passwordEncoder.encode(request.password),
        )
        return UserResponse.from(userRepository.save(user))
    }

    /**
     * 사용자 로그인을 처리합니다.
     *
     * 이메일 미존재 및 비밀번호 불일치 시 동일한 에러를 반환하여 계정 존재 여부를 노출하지 않습니다.
     *
     * @throws BusinessException [ErrorCode.INVALID_CREDENTIALS] - 이메일 또는 비밀번호 오류
     */
    fun login(request: UserLoginRequest): TokenResponse {
        val user = userRepository.findByEmail(request.email)
            ?: throw BusinessException(ErrorCode.INVALID_CREDENTIALS)

        if (!passwordEncoder.matches(request.password, user.passwordHash)) {
            throw BusinessException(ErrorCode.INVALID_CREDENTIALS)
        }

        val token = jwtTokenProvider.generateToken(user.id, user.email, "ROLE_USER")
        return TokenResponse(accessToken = token)
    }
}
