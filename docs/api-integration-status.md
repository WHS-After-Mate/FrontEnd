# API 연동 현황

> 백엔드에서 구현 완료된 API 목록과 프론트엔드 연동 상태를 추적하는 문서.
> 연동 완료 시 체크박스(☑)를 표시하고, 날짜와 담당 화면을 기록한다.

**백엔드 Base URL**: `/api/v1`  
**인증 방식**: `Authorization: Bearer {accessToken}`  
**백엔드 레포**: https://github.com/WHS-After-Mate/Backend

---

## 연동 진행률

| 섹션 | 전체 | 완료 | 진행률 |
|------|------|------|--------|
| 1. 인증/온보딩 | 7 | 7 | 100% |
| 2. 홈 | 3 | 3 | 100% |
| 3. 사후관리/Q&A | 4 | 4 | 100% |
| 4. My Care | 5 | 5 | 100% |
| 5. 설정/프로필 | 6 | 6 | 100% |
| **합계** | **25** | **25** | **100%** |

---

## 1. 인증 / 온보딩

| 상태 | Method | Endpoint | 설명 | 프론트 화면 | 연동일 |
|------|--------|----------|------|-------------|--------|
| ✅ | POST | `/auth/signup` | 환자번호+이름+생년월일 기반 회원가입 | `auth/sign_up_screen.dart` | 2026-08-16 |
| ✅ | POST | `/auth/login` | 이메일/비밀번호 로그인 | `auth/login_screen.dart` | 2026-08-16 |
| ✅ | POST | `/auth/refresh` | accessToken 재발급 | 공통(인터셉터) | 2026-08-16 |
| ✅ | POST | `/auth/logout` | 로그아웃 (refreshToken 무효화) | `settings/settings_screen.dart` | 2026-08-16 |
| ✅ | POST | `/auth/password/reset-request` | 비밀번호 재설정 이메일 발송 | `auth/reset_password_screen.dart` | 2026-08-16 |
| ✅ | POST | `/auth/password/reset-verify` | 인증코드 확인 → resetToken 발급 | `auth/reset_password_screen.dart` | 2026-08-16 |
| ✅ | POST | `/auth/password/reset-confirm` | 새 비밀번호 설정 | `auth/reset_password_screen.dart` | 2026-08-16 |

---

## 2. 홈

| 상태 | Method | Endpoint | 설명 | 프론트 화면 | 연동일 |
|------|--------|----------|------|-------------|--------|
| ✅ | GET | `/home/summary` | 홈 요약 (최근관리, 사후관리카드, 이용권, 추천) | `home/home_screen.dart` | 2026-08-16 |
| ✅ | GET | `/recommendations/next-care` | 다음 관리 추천 | `ai_recommend/ai_recommend_screen.dart` | 2026-08-16 |
| ✅ | GET | `/recommendations/next-care/{id}` | 추천 상세 | `ai_recommend/ai_recommend_screen.dart` | 2026-08-16 |

---

## 3. 사후관리 안내 및 Q&A (LLM 기반)

| 상태 | Method | Endpoint | 설명 | 프론트 화면 | 연동일 |
|------|--------|----------|------|-------------|--------|
| ✅ | GET | `/aftercare/daily-guide` | 일차별 사후관리 가이드 | `aiguide/aiguide_detail_screen.dart` | 2026-08-17 |
| ✅ | GET | `/aftercare/question-categories` | 질문 카테고리 목록 | `chat/ai_chat_screen.dart` | 2026-08-17 |
| ✅ | POST | `/aftercare/questions` | 챗봇 질문 → LLM 답변 | `chat/ai_chat_screen.dart` | 2026-08-17 |
| ✅ | GET | `/aftercare/questions` | 내 질문 이력 조회 | `chat/ai_chat_screen.dart` | 2026-08-17 |

---

## 4. My Care — 관리 이력 및 이용권

| 상태 | Method | Endpoint | 설명 | 프론트 화면 | 연동일 |
|------|--------|----------|------|-------------|--------|
| ✅ | GET | `/care-records/calendar` | 캘린더 월별 마커 | `mycare/mycare_screen.dart` | 2026-08-17 |
| ✅ | GET | `/care-records` | 관리 이력 목록 | `mycare/mycare_screen.dart` | 2026-08-17 |
| ✅ | GET | `/care-records/{id}` | 관리 상세 | `mycare/care_detail_screen.dart` | 2026-08-17 |
| ✅ | GET | `/memberships` | 이용권 목록 | `mycare/mycare_screen.dart` | 2026-08-17 |
| ✅ | GET | `/memberships/{id}` | 이용권 상세 | `mycare/mycare_screen.dart` | 2026-08-17 |

---

## 5. 설정 / 프로필

| 상태 | Method | Endpoint | 설명 | 프론트 화면 | 연동일 |
|------|--------|----------|------|-------------|--------|
| ✅ | GET | `/profile` | 프로필 조회 | `settings/my_info_screen.dart` | 2026-08-17 |
| ✅ | PATCH | `/profile` | 프로필 수정 (이름, 생년월일) | `settings/my_info_screen.dart` | 2026-08-17 |
| ✅ | POST | `/profile/password` | 비밀번호 변경 | `settings/my_info_screen.dart` | 2026-08-17 |
| ✅ | PUT | `/profile/interests` | 관심 목표 설정 | `settings/my_info_screen.dart` | 2026-08-17 |
| ✅ | POST | `/notifications/device-token` | FCM 토큰 등록 | 공통(앱 시작) | 2026-08-17 |
| ✅ | DELETE | `/notifications/device-token` | FCM 토큰 해제 | 공통(로그아웃) | 2026-08-17 |

---

## 연동 완료 기록 방법

1. 해당 API 연동 코드 작성 완료 시 `⬜`를 `✅`로 변경
2. 연동일에 날짜 기입 (예: `2026-08-16`)
3. 상단 진행률 표 업데이트
4. 필요 시 아래 비고란에 특이사항 메모

---

## 비고

- ~~현재 프론트엔드에 HTTP 패키지 미설치 상태~~ → `dio 5.11.0`, `flutter_secure_storage 9.2.4` 설치 완료 (2026-08-16)
- ~~`services/`, `models/`, `providers/` 등 API 레이어 구조 생성 필요~~ → `lib/services/api/`, `lib/services/auth/` 생성 완료
- ~~토큰 저장소(`flutter_secure_storage` 등) 설정 필요~~ → `TokenManager` 싱글톤 구현 완료
- 회원가입 UI 변경: 전화번호 필드 제거, 환자번호(patientNo) 필드 추가 (API 스펙에 맞춤)
