/// GET /profile 응답
class UserProfile {
  final String userId;
  final String name;
  final String? birthDate;
  final String email;
  final String? phone;
  final List<String> interestGoals;

  UserProfile({
    required this.userId,
    required this.name,
    this.birthDate,
    required this.email,
    this.phone,
    required this.interestGoals,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] as String,
    name: json['name'] as String,
    birthDate: json['birthDate'] as String?,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    interestGoals: List<String>.from(json['interestGoals'] ?? []),
  );
}

/// PATCH /profile 요청
class ProfileUpdateRequest {
  final String? name;
  final String? birthDate;

  ProfileUpdateRequest({this.name, this.birthDate});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (birthDate != null) map['birthDate'] = birthDate;
    return map;
  }
}

/// POST /profile/password 요청
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  PasswordChangeRequest({required this.currentPassword, required this.newPassword});

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}

/// PUT /profile/interests 요청
class InterestsUpdateRequest {
  final List<String> goals;

  InterestsUpdateRequest({required this.goals});

  Map<String, dynamic> toJson() => {'goals': goals};
}

/// GET /profile/notifications 응답
class NotificationSettings {
  final bool careNotification;
  final bool marketingNotification;

  NotificationSettings({
    required this.careNotification,
    required this.marketingNotification,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
    careNotification: json['careNotification'] as bool? ?? true,
    marketingNotification: json['marketingNotification'] as bool? ?? true,
  );
}

/// PATCH /profile/notifications 요청
class NotificationSettingsUpdate {
  final bool? careNotification;
  final bool? marketingNotification;

  NotificationSettingsUpdate({this.careNotification, this.marketingNotification});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (careNotification != null) map['careNotification'] = careNotification;
    if (marketingNotification != null) map['marketingNotification'] = marketingNotification;
    return map;
  }
}
