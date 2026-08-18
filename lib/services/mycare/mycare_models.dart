/// GET /care-records/calendar 응답
class CareCalendar {
  final String month;
  final List<CareCalendarDate> dates;

  CareCalendar({required this.month, required this.dates});

  factory CareCalendar.fromJson(Map<String, dynamic> json) => CareCalendar(
    month: json['month'] as String,
    dates: (json['dates'] as List<dynamic>)
        .map((e) => CareCalendarDate.fromJson(e))
        .toList(),
  );
}

class CareCalendarDate {
  final String date;
  final int count;

  CareCalendarDate({required this.date, required this.count});

  factory CareCalendarDate.fromJson(Map<String, dynamic> json) => CareCalendarDate(
    date: json['date'] as String,
    count: json['count'] as int,
  );
}

/// GET /care-records 응답 아이템
class CareRecordItem {
  final String careRecordId;
  final String careName;
  final String careDate;
  final List<String> partOfBody;
  final String? brand;
  final String? practitioner;
  final String status;

  CareRecordItem({
    required this.careRecordId,
    required this.careName,
    required this.careDate,
    required this.partOfBody,
    this.brand,
    this.practitioner,
    required this.status,
  });

  factory CareRecordItem.fromJson(Map<String, dynamic> json) => CareRecordItem(
    careRecordId: json['careRecordId'] as String,
    careName: json['careName'] as String,
    careDate: json['careDate'] as String,
    partOfBody: List<String>.from(json['partOfBody'] ?? []),
    brand: json['brand'] as String?,
    practitioner: json['practitioner'] as String?,
    status: json['status'] as String? ?? 'completed',
  );
}

/// GET /care-records 페이지네이션 응답
class CareRecordList {
  final List<CareRecordItem> items;
  final int page;
  final int size;
  final int totalCount;

  CareRecordList({
    required this.items,
    required this.page,
    required this.size,
    required this.totalCount,
  });

  factory CareRecordList.fromJson(Map<String, dynamic> json) => CareRecordList(
    items: (json['items'] as List<dynamic>)
        .map((e) => CareRecordItem.fromJson(e))
        .toList(),
    page: json['page'] as int,
    size: json['size'] as int,
    totalCount: json['totalCount'] as int,
  );
}

/// GET /care-records/{id} 상세 응답
class CareRecordDetail {
  final String careRecordId;
  final String careName;
  final String careDate;
  final List<String> partOfBody;
  final String? brand;
  final String? practitioner;
  final String status;
  final int daysElapsed;
  final CareSession? session;
  final CareMembership? membership;
  final List<String> basicAftercareGuide;

  CareRecordDetail({
    required this.careRecordId,
    required this.careName,
    required this.careDate,
    required this.partOfBody,
    this.brand,
    this.practitioner,
    required this.status,
    required this.daysElapsed,
    this.session,
    this.membership,
    required this.basicAftercareGuide,
  });

  factory CareRecordDetail.fromJson(Map<String, dynamic> json) => CareRecordDetail(
    careRecordId: json['careRecordId'] as String,
    careName: json['careName'] as String,
    careDate: json['careDate'] as String,
    partOfBody: List<String>.from(json['partOfBody'] ?? []),
    brand: json['brand'] as String?,
    practitioner: json['practitioner'] as String?,
    status: json['status'] as String? ?? 'completed',
    daysElapsed: json['daysElapsed'] as int,
    session: json['session'] != null ? CareSession.fromJson(json['session']) : null,
    membership: json['membership'] != null ? CareMembership.fromJson(json['membership']) : null,
    basicAftercareGuide: List<String>.from(json['basicAftercareGuide'] ?? []),
  );
}

class CareSession {
  final int number;
  final int total;

  CareSession({required this.number, required this.total});

  factory CareSession.fromJson(Map<String, dynamic> json) => CareSession(
    number: json['number'] as int,
    total: json['total'] as int,
  );
}

class CareMembership {
  final String membershipId;
  final String productName;
  final int? totalCount;

  CareMembership({required this.membershipId, required this.productName, this.totalCount});

  factory CareMembership.fromJson(Map<String, dynamic> json) => CareMembership(
    membershipId: json['membershipId'] as String,
    productName: json['productName'] as String,
    totalCount: json['totalCount'] as int?,
  );
}

/// GET /memberships 응답 아이템
class MembershipItem {
  final String membershipId;
  final String productName;
  final String? brand;
  final int totalCount;
  final int usedCount;
  final int remainingCount;
  final String? expiresAt;
  final String? lastUsedAt;
  final List<String> availableCareNames;
  final List<MembershipUsage> usageHistory;

  MembershipItem({
    required this.membershipId,
    required this.productName,
    this.brand,
    required this.totalCount,
    required this.usedCount,
    required this.remainingCount,
    this.expiresAt,
    this.lastUsedAt,
    required this.availableCareNames,
    required this.usageHistory,
  });

  factory MembershipItem.fromJson(Map<String, dynamic> json) => MembershipItem(
    membershipId: json['membershipId'] as String,
    productName: json['productName'] as String,
    brand: json['brand'] as String?,
    totalCount: json['totalCount'] as int,
    usedCount: json['usedCount'] as int,
    remainingCount: json['remainingCount'] as int,
    expiresAt: json['expiresAt'] as String?,
    lastUsedAt: json['lastUsedAt'] as String?,
    availableCareNames: List<String>.from(json['availableCareNames'] ?? []),
    usageHistory: (json['usageHistory'] as List<dynamic>?)
        ?.map((e) => MembershipUsage.fromJson(e))
        .toList() ?? [],
  );
}

class MembershipUsage {
  final int sessionNumber;
  final String usedAt;

  MembershipUsage({required this.sessionNumber, required this.usedAt});

  factory MembershipUsage.fromJson(Map<String, dynamic> json) => MembershipUsage(
    sessionNumber: json['sessionNumber'] as int,
    usedAt: json['usedAt'] as String,
  );
}
