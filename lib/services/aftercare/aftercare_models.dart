/// GET /aftercare/daily-guide 응답
class DailyGuide {
  final String guideId;
  final String careRecordId;
  final String careName;
  final int daysElapsed;
  final String elapsedRange;
  final bool isToday;
  final List<String> mustAvoid;
  final List<String> basicCare;
  final String? nextCheckDate;
  final String generatedAt;
  final String generatedBy;
  final String cacheExpiresAt;

  DailyGuide({
    required this.guideId,
    required this.careRecordId,
    required this.careName,
    required this.daysElapsed,
    required this.elapsedRange,
    required this.isToday,
    required this.mustAvoid,
    required this.basicCare,
    this.nextCheckDate,
    required this.generatedAt,
    required this.generatedBy,
    required this.cacheExpiresAt,
  });

  factory DailyGuide.fromJson(Map<String, dynamic> json) => DailyGuide(
    guideId: json['guideId'] as String,
    careRecordId: json['careRecordId'] as String,
    careName: json['careName'] as String,
    daysElapsed: json['daysElapsed'] as int,
    elapsedRange: json['elapsedRange'] as String,
    isToday: json['isToday'] as bool? ?? false,
    mustAvoid: List<String>.from(json['mustAvoid'] ?? []),
    basicCare: List<String>.from(json['basicCare'] ?? []),
    nextCheckDate: json['nextCheckDate'] as String?,
    generatedAt: json['generatedAt'] as String,
    generatedBy: json['generatedBy'] as String,
    cacheExpiresAt: json['cacheExpiresAt'] as String,
  );
}

/// GET /aftercare/question-categories 응답
class QuestionCategories {
  final List<String> categories;

  QuestionCategories({required this.categories});

  factory QuestionCategories.fromJson(Map<String, dynamic> json) =>
      QuestionCategories(categories: List<String>.from(json['categories'] ?? []));
}

/// POST /aftercare/questions 요청
class QuestionRequest {
  final String? careRecordId;
  final String category;
  final String question;

  QuestionRequest({
    this.careRecordId,
    required this.category,
    required this.question,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'category': category,
      'question': question,
    };
    if (careRecordId != null) map['careRecordId'] = careRecordId;
    return map;
  }
}

/// POST /aftercare/questions 응답 (정상 답변)
class QuestionResponse {
  final String questionId;
  final String status; // answered | out_of_scope | expert_required
  final String? answer;
  final String? answeredBy;
  final String? message;
  final bool expertContactRequired;
  final String consultationLevel; // NONE | RECOMMENDED | URGENT
  final QuestionBasis? basedOn;

  QuestionResponse({
    required this.questionId,
    required this.status,
    this.answer,
    this.answeredBy,
    this.message,
    this.expertContactRequired = false,
    this.consultationLevel = 'NONE',
    this.basedOn,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) => QuestionResponse(
    questionId: json['questionId'] as String,
    status: json['status'] as String,
    answer: json['answer'] as String?,
    answeredBy: json['answeredBy'] as String?,
    message: json['message'] as String?,
    expertContactRequired: json['expertContactRequired'] as bool? ?? false,
    consultationLevel: _parseConsultationLevel(json['consultationLevel']),
    basedOn: json['basedOn'] != null
        ? QuestionBasis.fromJson(json['basedOn'])
        : null,
  );

  static String _parseConsultationLevel(dynamic value) {
    if (value == null) return 'NONE';
    final str = value.toString().toUpperCase();
    if (str == 'RECOMMENDED' || str == 'URGENT') return str;
    return 'NONE';
  }
}

/// 답변 근거
class QuestionBasis {
  final String careRecordId;
  final int daysElapsed;
  final String guideId;

  QuestionBasis({
    required this.careRecordId,
    required this.daysElapsed,
    required this.guideId,
  });

  factory QuestionBasis.fromJson(Map<String, dynamic> json) => QuestionBasis(
    careRecordId: json['careRecordId'] as String,
    daysElapsed: json['daysElapsed'] as int,
    guideId: json['guideId'] as String,
  );
}

/// GET /aftercare/questions 응답 아이템
class QuestionHistoryItem {
  final String questionId;
  final String? careRecordId;
  final String category;
  final String question;
  final String status;
  final String? answer;
  final String? answeredBy;
  final bool expertContactRequired;
  final String createdAt;

  QuestionHistoryItem({
    required this.questionId,
    this.careRecordId,
    required this.category,
    required this.question,
    required this.status,
    this.answer,
    this.answeredBy,
    this.expertContactRequired = false,
    required this.createdAt,
  });

  factory QuestionHistoryItem.fromJson(Map<String, dynamic> json) => QuestionHistoryItem(
    questionId: json['questionId'] as String,
    careRecordId: json['careRecordId'] as String?,
    category: json['category'] as String,
    question: json['question'] as String,
    status: json['status'] as String,
    answer: json['answer'] as String?,
    answeredBy: json['answeredBy'] as String?,
    expertContactRequired: json['expertContactRequired'] as bool? ?? false,
    createdAt: json['createdAt'] as String,
  );
}
