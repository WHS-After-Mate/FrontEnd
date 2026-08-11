# 로그인/회원가입/비밀번호 재설정 레이아웃 구현 계획

제공해주신 디자인 지침에 따라 `fragment_login.xml`, `fragment_sign_up.xml`, `fragment_reset_password.xml` 3개 화면의 레이아웃을 구현합니다. 모든 디자인 요소는 하드코딩 없이 리소스를 참조하도록 구성하겠습니다.

## Proposed Changes

### 1. Resource Setup (리소스 설정)
레이아웃 구성에 필요한 공통 리소스를 먼저 정의합니다.

#### [MODIFY] [colors.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/values/colors.xml)
- 텍스트 라벨, 힌트, 테두리 등에 사용할 회색 계열 색상 추가 (`gray_text_label`, `gray_text_hint`, `gray_border`).

#### [NEW] [bg_edittext.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/drawable/bg_edittext.xml)
- 입력창(EditText)의 배경 (흰색 배경 + 회색 테두리 + 8dp 라운드).

#### [NEW] [bg_button_black.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/drawable/bg_button_black.xml)
- 메인 버튼의 배경 (검은색 배경 + 8dp 라운드).

#### [NEW] [ic_back.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/drawable/ic_back.xml)
- 상단 네비게이션을 위한 뒤로가기 아이콘 (Vector).

---

### 2. Layout Implementation (레이아웃 구현)

#### [MODIFY] [fragment_reset_password.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_reset_password.xml)
- 뒤로가기 버튼, 타이틀, 설명 문구, 이메일 입력 필드, 하단 고정 "재설정 링크 보내기" 버튼 구현.

#### [MODIFY] [fragment_login.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_login.xml)
- 로고(`logo_black`), 타이틀, 이메일/비밀번호 입력 폼, "비밀번호를 잊으셨나요?" 링크, 로그인 버튼, 하단 회원가입 유도 문구 구현.

#### [MODIFY] [fragment_sign_up.xml](file:///C:/Users/LG/OneDrive/Desktop/FrontEnt_new/app/src/main/res/layout/fragment_sign_up.xml)
- 뒤로가기 버튼, 타이틀, 이름/이메일/휴대폰/비밀번호 입력 폼, "가입하고 시작하기" 버튼 구현.

## Verification Plan

### Automated Tests
- `gradlew assembleDebug`를 실행하여 레이아웃 파일의 문법 오류 및 리소스 참조 오류가 없는지 확인합니다.

### Manual Verification
- Android Studio의 **Layout Layout Editor Preview**를 통해 각 화면의 UI가 디자인 시안과 일치하는지 확인합니다.
