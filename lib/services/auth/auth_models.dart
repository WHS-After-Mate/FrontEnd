/// 로그인 요청
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

/// 회원가입 요청
class SignupRequest {
  final String patientNo;
  final String name;
  final String birthDate;
  final String phone;
  final String email;
  final String password;
  final List<String> interestGoals;

  SignupRequest({
    required this.patientNo,
    required this.name,
    required this.birthDate,
    required this.phone,
    required this.email,
    required this.password,
    this.interestGoals = const [],
  });

  Map<String, dynamic> toJson() => {
    'patientNo': patientNo,
    'name': name,
    'birthDate': birthDate,
    'phone': phone,
    'email': email,
    'password': password,
    'interestGoals': interestGoals,
  };
}

/// 비밀번호 재설정 - 이메일 발송 요청
class PasswordResetRequest {
  final String email;

  PasswordResetRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

/// 비밀번호 재설정 - 인증코드 확인 요청
class PasswordResetVerify {
  final String email;
  final String code;

  PasswordResetVerify({required this.email, required this.code});

  Map<String, dynamic> toJson() => {
    'email': email,
    'code': code,
  };
}

/// 비밀번호 재설정 - 새 비밀번호 확정 요청
class PasswordResetConfirm {
  final String resetToken;
  final String newPassword;

  PasswordResetConfirm({required this.resetToken, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'resetToken': resetToken,
    'newPassword': newPassword,
  };
}

/// 인증 응답 (login, signup 공통)
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final AuthUser user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresIn: json['expiresIn'] as int,
    user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}

/// 로그인된 사용자 기본 정보
class AuthUser {
  final String id;
  final String name;
  final String role;

  AuthUser({required this.id, required this.name, required this.role});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    name: json['name'] as String,
    role: json['role'] as String,
  );
}

/// 비밀번호 재설정 인증코드 확인 응답
class PasswordResetVerifyResponse {
  final String resetToken;

  PasswordResetVerifyResponse({required this.resetToken});

  factory PasswordResetVerifyResponse.fromJson(Map<String, dynamic> json) =>
      PasswordResetVerifyResponse(resetToken: json['resetToken'] as String);
}
