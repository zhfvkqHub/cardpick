# CardPick

소비 패턴 기반 신용카드 추천 서비스

사용자의 카테고리별 월 소비액을 분석하여 최적의 신용카드를 추천하고, 예상 절감액을 계산해줍니다.

## 주요 기능

- **소비 패턴 입력** — 카테고리별 월 소비액 직접 입력 / CSV 업로드
- **최적 카드 매칭** — 소비 패턴에 가장 유리한 카드 조합 추천
- **절감액 계산** — 현재 카드 대비 추천 카드의 예상 절감액 산출

## 기술 스택

| 영역 | 기술 |
|------|------|
| Backend | Kotlin + Spring Boot 4.0 |
| Frontend | Flutter |
| Database | PostgreSQL |
| Cache | Redis |
| Runtime | Java 21 |

## 프로젝트 구조

```
cardpick/
├── cardpick-service/    # Backend (Kotlin + Spring Boot)
└── cardpick-app/        # Frontend (Flutter)
```

## 실행 방법

### 사전 요구사항

- Java 21
- PostgreSQL 16+
- Redis 7+

### 빌드 및 실행

```bash
cd cardpick-service
./gradlew bootRun
```

## API 엔드포인트

| 기능 | Method | Endpoint |
|------|--------|----------|
| 카드 목록 조회 | GET | `/api/v1/cards` |
| 소비 프로필 입력 | PUT | `/api/v1/spending-profiles` |
| CSV 업로드 | POST | `/api/v1/spending-profiles/csv` |
| 카드 추천 요청 | POST | `/api/v1/recommendations` |
| 최근 추천 조회 | GET | `/api/v1/recommendations/latest` |
| 회원가입 | POST | `/api/v1/auth/signup` |
| 로그인 | POST | `/api/v1/auth/login` |
