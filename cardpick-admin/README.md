# CardPick Admin

CardPick 서비스의 관리자 페이지입니다. 카드 및 혜택 데이터를 등록/수정/삭제할 수 있습니다.

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Vue 3 + TypeScript |
| Build | Vite 8 |
| UI | Element Plus |
| 상태 관리 | Pinia |
| HTTP | Axios |
| 라우팅 | Vue Router 4 |

## 주요 화면

| 화면 | 경로 | 설명 |
|------|------|------|
| 로그인 | `/login` | 관리자 JWT 인증 |
| 대시보드 | `/` | 등록 카드 수, 활성/비활성 통계, 최근 등록 카드 |
| 카드 목록 | `/cards` | 카드 목록 조회, 검색, 삭제 |
| 카드 등록 | `/cards/create` | 카드 정보 입력 폼 |
| 카드 수정 | `/cards/:id/edit` | 카드 정보 수정 + 혜택 CRUD |

## 프로젝트 구조

```
src/
├── api/                # API 호출 모듈
│   ├── index.ts        # Axios 인스턴스 (인터셉터, 토큰 주입)
│   ├── auth.ts         # 인증 API
│   └── card.ts         # 카드/혜택 API
├── layouts/
│   └── AdminLayout.vue # 사이드바 + 헤더 레이아웃
├── router/
│   └── index.ts        # 라우팅 설정 (인증 가드 포함)
├── stores/
│   └── auth.ts         # 인증 상태 (Pinia)
├── views/
│   ├── LoginView.vue       # 로그인 페이지
│   ├── DashboardView.vue   # 대시보드
│   ├── CardListView.vue    # 카드 목록
│   └── CardFormView.vue    # 카드 등록/수정
├── App.vue
├── main.ts
└── style.css
```

## 실행 방법

### 사전 요구사항

- Node.js 18+
- cardpick-service 백엔드 실행 중 (localhost:8080)

### 설치 및 실행

```bash
npm install
npm run dev
```

브라우저에서 http://localhost:5173 으로 접속합니다.

### 프로덕션 빌드

```bash
npm run build
```

`dist/` 디렉토리에 빌드 결과물이 생성됩니다.

## 백엔드 API 연동

개발 환경에서는 Vite 프록시를 통해 `/api` 요청이 `localhost:8080`으로 전달됩니다.

### 관리자 API 목록

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/admin/auth/login` | 관리자 로그인 (JWT 발급) |
| GET | `/api/admin/cards` | 카드 목록 조회 |
| GET | `/api/admin/cards/{id}` | 카드 상세 조회 (혜택 포함) |
| POST | `/api/admin/cards` | 카드 등록 |
| PUT | `/api/admin/cards/{id}` | 카드 수정 |
| DELETE | `/api/admin/cards/{id}` | 카드 삭제 |
| POST | `/api/admin/cards/{id}/benefits` | 혜택 등록 |
| PUT | `/api/admin/cards/benefits/{id}` | 혜택 수정 |
| DELETE | `/api/admin/cards/benefits/{id}` | 혜택 삭제 |
