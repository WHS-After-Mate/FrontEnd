import 'package:flutter/services.dart';

// === 유효성 검사 ===

String? validateEmail(String value) {
  if (value.isEmpty) return null;
  final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
  if (!regex.hasMatch(value)) {
    return '올바른 이메일 형식을 입력해주세요';
  }
  return null;
}

String? validatePassword(String value) {
  if (value.isEmpty) return null;
  if (value.length < 8) {
    return '비밀번호는 8자 이상이어야 합니다';
  }
  return null;
}

String? validatePhone(String value) {
  if (value.isEmpty) return null;
  final regex = RegExp(r'^\d{3}-\d{4}-\d{4}$');
  if (!regex.hasMatch(value)) {
    return '010-0000-0000 형식으로 입력해주세요';
  }
  return null;
}

String? validateBirth(String value) {
  if (value.isEmpty) return null;
  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!regex.hasMatch(value)) {
    return 'YYYY-MM-DD 형식으로 입력해주세요';
  }
  return null;
}

// === 자동 포맷터 ===

/// 전화번호 자동 하이픈: 010-0000-0000
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 생년월일 자동 하이픈: YYYY-MM-DD
class BirthDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 4 || i == 6) buffer.write('-');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
