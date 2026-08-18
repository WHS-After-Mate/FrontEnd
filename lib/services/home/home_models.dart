/// GET /home/summary 응답 모델
class HomeSummary {
  final LatestCare? latestCare;
  final AftercareCard? aftercareCard;
  final MembershipSummary? membershipSummary;
  final HomeRecommendation? recommendation;

  HomeSummary({
    this.latestCare,
    this.aftercareCard,
    this.membershipSummary,
    this.recommendation,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) => HomeSummary(
    latestCare: json['latestCare'] != null
        ? LatestCare.fromJson(json['latestCare'])
        : null,
    aftercareCard: json['aftercareCard'] != null
        ? AftercareCard.fromJson(json['aftercareCard'])
        : null,
    membershipSummary: json['membershipSummary'] != null
        ? MembershipSummary.fromJson(json['membershipSummary'])
        : null,
    recommendation: json['recommendation'] != null
        ? HomeRecommendation.fromJson(json['recommendation'])
        : null,
  );
}

/// 최근 관리 요약
class LatestCare {
  final String careRecordId;
  final String careName;
  final String careDate;
  final int daysElapsed;
  final List<String> partOfBody;
  String? brand;

  LatestCare({
    required this.careRecordId,
    required this.careName,
    required this.careDate,
    required this.daysElapsed,
    required this.partOfBody,
    this.brand,
  });

  factory LatestCare.fromJson(Map<String, dynamic> json) => LatestCare(
    careRecordId: json['careRecordId'] as String,
    careName: json['careName'] as String,
    careDate: json['careDate'] as String,
    daysElapsed: json['daysElapsed'] as int,
    partOfBody: List<String>.from(json['partOfBody'] ?? []),
    brand: json['brand'] as String?,
  );
}

/// 사후관리 카드
class AftercareCard {
  final String guideId;
  final String elapsedRange;
  final List<String> cautions;
  final String? nextCheckDate;
  final String generatedAt;

  AftercareCard({
    required this.guideId,
    required this.elapsedRange,
    required this.cautions,
    this.nextCheckDate,
    required this.generatedAt,
  });

  factory AftercareCard.fromJson(Map<String, dynamic> json) => AftercareCard(
    guideId: json['guideId'] as String,
    elapsedRange: json['elapsedRange'] as String,
    cautions: List<String>.from(json['cautions'] ?? []),
    nextCheckDate: json['nextCheckDate'] as String?,
    generatedAt: json['generatedAt'] as String,
  );
}

/// 이용권 요약
class MembershipSummary {
  final int totalMemberships;
  final NearestExpiry? nearestExpiry;

  MembershipSummary({
    required this.totalMemberships,
    this.nearestExpiry,
  });

  factory MembershipSummary.fromJson(Map<String, dynamic> json) => MembershipSummary(
    totalMemberships: json['totalMemberships'] as int,
    nearestExpiry: json['nearestExpiry'] != null
        ? NearestExpiry.fromJson(json['nearestExpiry'])
        : null,
  );
}

/// 가장 임박한 이용권
class NearestExpiry {
  final String membershipId;
  final String expiresAt;
  final int remainingCount;

  NearestExpiry({
    required this.membershipId,
    required this.expiresAt,
    required this.remainingCount,
  });

  factory NearestExpiry.fromJson(Map<String, dynamic> json) => NearestExpiry(
    membershipId: json['membershipId'] as String,
    expiresAt: json['expiresAt'] as String,
    remainingCount: json['remainingCount'] as int,
  );
}

/// 홈 내 추천 카드 (간략)
class HomeRecommendation {
  final String recommendationId;
  final String careName;
  final List<String> reasons;

  HomeRecommendation({
    required this.recommendationId,
    required this.careName,
    required this.reasons,
  });

  factory HomeRecommendation.fromJson(Map<String, dynamic> json) => HomeRecommendation(
    recommendationId: json['recommendationId'] as String,
    careName: json['careName'] as String,
    reasons: List<String>.from(json['reasons'] ?? []),
  );
}

/// GET /recommendations/next-care 및 상세 응답 모델
class RecommendationDetail {
  final String recommendationId;
  final String careName;
  final List<String> reasons;
  final List<String> basis;
  final String disclaimer;
  final String? detailDescription;
  final List<String> categoryTags;
  final List<RelatedCare> relatedRecentCares;
  final List<String> popularWithSimilarCustomers;
  final List<ClinicContact> clinicContacts;

  RecommendationDetail({
    required this.recommendationId,
    required this.careName,
    required this.reasons,
    required this.basis,
    required this.disclaimer,
    this.detailDescription,
    this.categoryTags = const [],
    this.relatedRecentCares = const [],
    this.popularWithSimilarCustomers = const [],
    this.clinicContacts = const [],
  });

  factory RecommendationDetail.fromJson(Map<String, dynamic> json) => RecommendationDetail(
    recommendationId: json['recommendationId'] as String,
    careName: json['careName'] as String,
    reasons: List<String>.from(json['reasons'] ?? []),
    basis: List<String>.from(json['basis'] ?? []),
    disclaimer: json['disclaimer'] as String? ?? '',
    detailDescription: json['detailDescription'] as String?,
    categoryTags: List<String>.from(json['categoryTags'] ?? []),
    relatedRecentCares: (json['relatedRecentCares'] as List<dynamic>?)
        ?.map((e) => RelatedCare.fromJson(e))
        .toList() ?? [],
    popularWithSimilarCustomers:
        List<String>.from(json['popularWithSimilarCustomers'] ?? []),
    clinicContacts: (json['clinicContacts'] as List<dynamic>?)
        ?.map((e) => ClinicContact.fromJson(e))
        .toList() ?? [],
  );
}

/// 추천 상세 - 최근 관리
class RelatedCare {
  final String careRecordId;
  final String careName;
  final int daysElapsed;
  final String? brand;

  RelatedCare({
    required this.careRecordId,
    required this.careName,
    required this.daysElapsed,
    this.brand,
  });

  factory RelatedCare.fromJson(Map<String, dynamic> json) => RelatedCare(
    careRecordId: json['careRecordId'] as String,
    careName: json['careName'] as String,
    daysElapsed: json['daysElapsed'] as int,
    brand: json['brand'] as String?,
  );
}

/// 추천 상세 - 클리닉 연락처
class ClinicContact {
  final String brand;
  final String label;
  final String? talkChannelUrl;
  final String? phone;

  ClinicContact({required this.brand, required this.label, this.talkChannelUrl, this.phone});

  factory ClinicContact.fromJson(Map<String, dynamic> json) => ClinicContact(
    brand: json['brand'] as String,
    label: json['label'] as String,
    talkChannelUrl: json['talkChannelUrl'] as String?,
    phone: json['phone'] as String?,
  );
}
