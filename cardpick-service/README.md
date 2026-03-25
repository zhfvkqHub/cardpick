# CardPick Service - 소비 패턴 기반 신용카드 추천 API 서버

## 1. 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| Backend | Kotlin + Spring Boot | Kotlin 2.2.21, Spring Boot 4.0.4 |
| Runtime | Java | 21 (toolchain) |
| Database | PostgreSQL | 16+ |
| Cache | Redis | 7+ |
| Build | Gradle (Kotlin DSL) | 8.x |

---

## 2. 아키텍처

```
┌──────────────────┐
│   API Server     │
│  (Spring Boot)   │
└────────┬─────────┘
         │
    ┌────┼────────────┐
    │    │            │
┌───▼──┐ ┌───▼───┐ ┌──▼───────┐
│Recom-│ │       │ │          │
│mend  │ │ Redis │ │PostgreSQL│
│Engine│ │(Cache)│ │  (DB)    │
└──────┘ └───────┘ └──────────┘
```

### 주요 흐름
1. 클라이언트에서 카테고리별 월 소비액을 입력 (또는 CSV 업로드 → 자동 합산)
2. API Server가 소비 프로필을 저장
3. 추천 엔진이 카드 혜택 DB와 대조하여 최적 카드 매칭
4. 추천 결과와 절감액을 클라이언트에 반환
5. Redis로 카드 혜택 정보 및 추천 결과 캐싱

---

## 3. 데이터 전략

### 3.1 카드 혜택 데이터: 정적 DB 직접 구축

카드사 웹사이트 크롤링 대신 **수동으로 카드 혜택 정보를 DB에 입력**한다.

- **대상**: 주요 카드사(신한, 삼성, KB, 현대, 롯데 등)의 인기 카드 20~30장
- **입력 정보**: 카드명, 연회비, 카테고리별 할인율/적립율, 전월 실적 조건, 할인 한도
- **관리**: 관리자 API를 통해 신규 카드 추가 및 혜택 정보 업데이트

### 3.2 소비 데이터 입력 전략

| 방법 | 설명 | 대상 |
|------|------|------|
| **카테고리별 월 소비액 입력 (기본)** | 식비, 교통, 쇼핑 등 카테고리별 월 소비액을 직접 입력 | 모든 사용자 |
| **CSV 업로드 (선택)** | 카드사에서 다운로드한 이용내역 CSV를 업로드 → 자동 카테고리 분류 → 월 소비액 합산 | 정밀 분석 원하는 사용자 |

### 3.3 AI 활용 영역

| 영역 | 활용 방식 |
|------|----------|
| CSV 카테고리 분류 | 가맹점명 → 카테고리 자동 분류 (CSV 업로드 시) |
| 추천 로직 | 소비 패턴과 카드 혜택 매칭 최적화 |
| 절감액 계산 | 전월 실적 조건, 할인 한도 등 복합 조건 반영 |

---

## 4. DB 스키마 설계

### 4.1 cards (카드 기본 정보)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | BIGSERIAL | PK |
| card_company | VARCHAR(50) | 카드사 (신한, 삼성 등) |
| card_name | VARCHAR(100) | 카드 상품명 |
| annual_fee | INTEGER | 연회비 (원) |
| minimum_spending | INTEGER | 전월 최소 실적 (원) |
| card_type | VARCHAR(20) | 신용/체크 |
| image_url | VARCHAR(500) | 카드 이미지 URL |
| description | TEXT | 카드 설명 |
| is_active | BOOLEAN | 활성 여부 |
| created_at | TIMESTAMP | 생성일시 |
| updated_at | TIMESTAMP | 수정일시 |

### 4.2 card_benefits (카드별 카테고리 혜택)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | BIGSERIAL | PK |
| card_id | BIGINT | FK → cards.id |
| category | VARCHAR(50) | 혜택 카테고리 (식비, 교통 등) |
| benefit_type | VARCHAR(20) | 할인/적립/캐시백 |
| benefit_rate | DECIMAL(5,2) | 혜택률 (%) |
| benefit_limit | INTEGER | 월 한도 (원) |
| minimum_amount | INTEGER | 최소 결제 금액 (원) |
| description | TEXT | 상세 조건 설명 |

### 4.3 users (사용자)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | BIGSERIAL | PK |
| email | VARCHAR(255) | 이메일 (로그인) |
| nickname | VARCHAR(50) | 닉네임 |
| password_hash | VARCHAR(255) | 비밀번호 해시 |
| created_at | TIMESTAMP | 가입일시 |
| updated_at | TIMESTAMP | 수정일시 |

### 4.4 spending_profiles (카테고리별 월 소비 프로필)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | BIGSERIAL | PK |
| user_id | BIGINT | FK → users.id |
| category | VARCHAR(50) | 소비 카테고리 (식비, 교통 등) |
| monthly_amount | INTEGER | 월 평균 소비 금액 (원) |
| created_at | TIMESTAMP | 생성일시 |
| updated_at | TIMESTAMP | 수정일시 |

### 4.5 recommendations (추천 결과)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | BIGSERIAL | PK |
| user_id | BIGINT | FK → users.id |
| card_id | BIGINT | FK → cards.id |
| estimated_saving | INTEGER | 예상 월 절감액 (원) |
| rank | INTEGER | 추천 순위 |
| reason | TEXT | 추천 사유 |
| analysis_period_start | DATE | 분석 기간 시작 |
| analysis_period_end | DATE | 분석 기간 종료 |
| created_at | TIMESTAMP | 생성일시 |

### ER 다이어그램

```
users 1──N spending_profiles
users 1──N recommendations
cards 1──N card_benefits
cards 1──N recommendations
```

---

## 5. API 설계

### 5.1 카드 관리

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/api/v1/cards` | 카드 목록 조회 |
| GET | `/api/v1/cards/{id}` | 카드 상세 조회 |
| POST | `/api/v1/cards` | 카드 등록 (관리자) |
| PUT | `/api/v1/cards/{id}` | 카드 수정 (관리자) |
| DELETE | `/api/v1/cards/{id}` | 카드 삭제 (관리자) |
| GET | `/api/v1/cards/{id}/benefits` | 카드 혜택 조회 |
| POST | `/api/v1/cards/{id}/benefits` | 카드 혜택 등록 (관리자) |

### 5.2 소비 프로필

| Method | Endpoint | 설명 |
|--------|----------|------|
| GET | `/api/v1/spending-profiles` | 내 소비 프로필 조회 |
| PUT | `/api/v1/spending-profiles` | 카테고리별 월 소비액 입력/수정 |
| POST | `/api/v1/spending-profiles/csv` | CSV 업로드 → 자동 분류 → 소비 프로필 생성 |
| DELETE | `/api/v1/spending-profiles` | 소비 프로필 초기화 |

### 5.3 추천

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/recommendations` | 카드 추천 요청 |
| GET | `/api/v1/recommendations/latest` | 최근 추천 결과 조회 |
| GET | `/api/v1/recommendations/{id}` | 추천 상세 조회 |

### 5.4 인증

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/auth/signup` | 회원가입 |
| POST | `/api/v1/auth/login` | 로그인 |
| POST | `/api/v1/auth/refresh` | 토큰 갱신 |

---

## 6. 개발 로드맵

### Phase 1: 프로젝트 기반 구축
- Spring Boot 프로젝트 설정 (완료)
- PostgreSQL, Redis 연동 설정
- JPA Entity 및 Repository 구성
- 기본 예외 처리 및 응답 형식 통일

### Phase 2: 카드 데이터 관리
- 카드 CRUD API 구현
- 카드 혜택 등록/조회 API 구현
- 주요 카드 20~30장 초기 데이터 입력
- Redis 캐싱 적용 (카드 목록)

### Phase 3: 소비 프로필 관리
- 카테고리별 월 소비액 입력/수정 API 구현
- CSV 업로드 → 카테고리 자동 분류 → 월 소비액 합산 기능
- 소비 프로필 조회/초기화 API 구현

### Phase 4: 추천 엔진
- 소비 패턴 분석 로직 구현
- 카드-소비 매칭 알고리즘 구현
- 절감액 계산 로직 (전월 실적, 할인 한도 반영)
- 추천 결과 저장 및 조회 API 구현

### Phase 5: 인증 및 보안
- JWT 기반 인증 구현
- 회원가입/로그인 API 구현
- API 접근 권한 관리 (일반 사용자/관리자)
- 입력값 검증 및 보안 강화

---

## 7. 디렉토리 구조

```
src/main/kotlin/org/card/cardservice/
├── CardServiceApplication.kt
├── config/                  # 설정 (Redis, Security, Web 등)
├── domain/                  # 도메인 엔티티
│   ├── card/
│   ├── user/
│   ├── spending/
│   └── recommendation/
├── repository/              # JPA Repository
├── service/                 # 비즈니스 로직
├── controller/              # REST Controller
├── dto/                     # 요청/응답 DTO
│   ├── request/
│   └── response/
└── exception/               # 예외 처리
```
