package org.card.cardservice.exception

import org.springframework.http.HttpStatus

enum class ErrorCode(
    val status: HttpStatus,
    val code: String,
    val message: String,
) {
    // Auth
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "AUTH_001", "아이디 또는 비밀번호가 올바르지 않습니다"),
    INVALID_TOKEN(HttpStatus.UNAUTHORIZED, "AUTH_002", "유효하지 않은 토큰입니다"),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "AUTH_003", "접근 권한이 없습니다"),

    // Card
    CARD_NOT_FOUND(HttpStatus.NOT_FOUND, "CARD_001", "카드를 찾을 수 없습니다"),
    DUPLICATE_CARD(HttpStatus.CONFLICT, "CARD_002", "이미 등록된 카드입니다"),

    // Benefit
    BENEFIT_NOT_FOUND(HttpStatus.NOT_FOUND, "BENEFIT_001", "혜택을 찾을 수 없습니다"),

    // User
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "USER_001", "이미 사용 중인 이메일입니다"),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "USER_002", "사용자를 찾을 수 없습니다"),

    // Spending Profile
    SPENDING_PROFILE_NOT_FOUND(HttpStatus.NOT_FOUND, "SPENDING_001", "소비 프로필을 찾을 수 없습니다"),
    SPENDING_PROFILE_EMPTY(HttpStatus.BAD_REQUEST, "SPENDING_002", "소비 프로필이 비어있습니다"),

    // Recommendation
    RECOMMENDATION_NOT_FOUND(HttpStatus.NOT_FOUND, "RECOMMEND_001", "추천 결과를 찾을 수 없습니다"),
    NO_ACTIVE_CARDS(HttpStatus.BAD_REQUEST, "RECOMMEND_002", "활성화된 카드가 없습니다"),

    // Common
    INVALID_INPUT(HttpStatus.BAD_REQUEST, "COMMON_001", "입력값이 올바르지 않습니다"),
    INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "COMMON_002", "서버 내부 오류가 발생했습니다"),
    INVALID_CATEGORY(HttpStatus.BAD_REQUEST, "COMMON_003", "유효하지 않은 카테고리입니다"),
}
