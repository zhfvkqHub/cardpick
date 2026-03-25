# CardPick App

CardPick 서비스의 사용자 모바일 앱입니다. 소비 패턴을 분석하여 최적의 신용카드를 추천합니다.

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Flutter |
| 언어 | Dart |
| 상태 관리 | Riverpod |
| HTTP | Dio |
| 라우팅 | GoRouter |

## 프로젝트 구조

```
lib/
├── main.dart
├── app/
│   ├── router.dart          # GoRouter 설정
│   └── theme.dart           # 앱 테마
├── features/
│   ├── auth/                # 로그인/회원가입
│   ├── spending/            # 소비 패턴 입력
│   ├── recommendation/      # 추천 결과
│   └── card/                # 카드 상세
├── shared/
│   ├── models/              # 데이터 모델
│   ├── providers/           # Riverpod 프로바이더
│   ├── services/            # API 서비스
│   └── widgets/             # 공통 위젯
└── core/
    ├── network/             # Dio 설정, 인터셉터
    └── constants/           # 상수 정의
```

## 주요 화면 및 작업 목록

### 1. 인증 (Auth)

- [ ] **로그인 화면** — 이메일/비밀번호 입력, JWT 토큰 저장
- [ ] **회원가입 화면** — 이름/이메일/비밀번호 입력 및 유효성 검사
- [ ] **토큰 자동 갱신** — Dio 인터셉터에서 401 응답 처리 (토큰 만료 시 재로그인 유도)

### 2. 소비 패턴 입력 (Spending)

- [ ] **소비 프로필 조회 화면** — 등록된 카테고리별 월 소비액 목록 표시
- [ ] **소비 프로필 등록/수정 화면** — 카테고리 선택 + 금액 입력 폼 (PUT /api/v1/spending-profiles)
  - 카테고리 선택 UI (식비, 교통, 쇼핑, 주유 등)
  - 월 소비 금액 입력 (원 단위, 양수만 허용)
  - 항목 추가/삭제
- [ ] **소비 프로필 초기화** — DELETE /api/v1/spending-profiles

### 3. 카드 추천 (Recommendation)

- [ ] **추천 요청 화면** — 소비 프로필 기반 추천 실행 버튼 (POST /api/v1/recommendations)
- [ ] **추천 결과 화면** — 순위별 카드 목록 표시
  - 카드명, 카드사, 연회비
  - 총 절감액 (`totalSaving`), 순 절감액 (`netSaving`, 연회비 차감)
  - 카드 상세 화면으로 이동
- [ ] **최근 추천 결과 조회** — 앱 진입 시 GET /api/v1/recommendations/latest로 이전 결과 복원

### 4. 카드 목록/상세 (Card)

- [ ] **카드 목록 화면** — 활성 카드 전체 목록 (GET /api/v1/cards)
  - 카드 이미지, 카드명, 카드사, 연회비 표시
- [ ] **카드 상세 화면** — 카드 혜택 정보 상세 표시 (GET /api/v1/cards/{id})
  - 카드 기본 정보 (연회비, 최소 이용금액, 카드 타입)
  - 혜택 목록: 카테고리, 혜택 유형(`benefitType`), 혜택률(`benefitRate`), 한도(`benefitLimit`), 최소 이용금액

### 5. 공통 (Core / Shared)

- [ ] **Dio 네트워크 설정** — baseUrl, 타임아웃 설정
- [ ] **JWT 인터셉터** — 요청 헤더에 `Authorization: Bearer <token>` 자동 삽입
- [ ] **에러 핸들링** — API 공통 에러 응답(`ApiResponse`) 파싱 및 사용자 안내 메시지
- [ ] **로컬 토큰 저장** — flutter_secure_storage 또는 shared_preferences 사용
- [ ] **공통 위젯** — 로딩 인디케이터, 에러 스낵바, 빈 상태 뷰

## 백엔드 API 연동

cardpick-service의 사용자 API(`/api/v1/**`)와 통신합니다.

### 인증 불필요 (Public)

| 기능 | Method | Endpoint | 요청 | 응답 |
|------|--------|----------|------|------|
| 회원가입 | POST | `/api/v1/auth/signup` | `{ name, email, password }` | `UserResponse` |
| 로그인 | POST | `/api/v1/auth/login` | `{ email, password }` | `{ accessToken, tokenType }` |
| 카드 목록 조회 | GET | `/api/v1/cards` | — | `List<CardResponse>` |
| 카드 상세 조회 | GET | `/api/v1/cards/{id}` | — | `CardDetailResponse` (혜택 포함) |

### 인증 필요 (JWT Bearer Token)

| 기능 | Method | Endpoint | 요청 | 응답 |
|------|--------|----------|------|------|
| 소비 프로필 조회 | GET | `/api/v1/spending-profiles` | — | `{ items: [{ id, category, monthlyAmount }] }` |
| 소비 프로필 등록/수정 | PUT | `/api/v1/spending-profiles` | `{ items: [{ category, monthlyAmount }] }` | `SpendingProfileResponse` |
| 소비 프로필 초기화 | DELETE | `/api/v1/spending-profiles` | — | — |
| 카드 추천 요청 | POST | `/api/v1/recommendations` | — | `RecommendationResponse` |
| 최근 추천 결과 조회 | GET | `/api/v1/recommendations/latest` | — | `RecommendationResponse` |
| 추천 상세 조회 | GET | `/api/v1/recommendations/{requestId}` | — | `RecommendationResponse` |

### 주요 응답 모델

```dart
// 추천 결과
RecommendationResponse {
  requestId: String,
  createdAt: DateTime,
  cards: [
    {
      rank: int,
      cardId: int,
      cardName: String,
      cardCompany: String,
      annualFee: int,
      totalSaving: double,   // 혜택으로 절감되는 총액
      netSaving: double,     // totalSaving - annualFee
    }
  ]
}

// 카드 상세 (혜택 포함)
CardDetailResponse {
  id, cardCompany, cardName, annualFee,
  minimumSpending, cardType, imageUrl, description,
  benefits: [
    {
      id, category, benefitType, benefitRate,
      benefitLimit, minimumAmount, description
    }
  ]
}
```

## 실행 방법

### 사전 요구사항

- Flutter SDK 3.x+
- Dart SDK 3.x+
- Android Studio 또는 Xcode (에뮬레이터/시뮬레이터)
- cardpick-service 백엔드 실행 중

### 설치 및 실행

```bash
flutter pub get
flutter run
```
