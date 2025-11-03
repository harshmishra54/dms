import 'dart:convert';

/// ------------------------
/// REQUEST MODEL
/// ------------------------
class LeaveCalendarRequest {
  final String id;

  LeaveCalendarRequest({required this.id});

  Map<String, dynamic> toJson() => {
    'id': id,
  };

  String toRawJson() => json.encode(toJson());
}

/// ------------------------
/// RESPONSE MODEL
/// ------------------------
class LeaveCalendarResponse {
  final int success;
  final String message;
  final List<LeaveData> data;

  LeaveCalendarResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LeaveCalendarResponse.fromJson(Map<String, dynamic> json) {
    return LeaveCalendarResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<LeaveData>.from(
          json['data'].map((x) => LeaveData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class LeaveData {
  final String id;
  final String holidayType;
  final DateTime holidayDate;
  final String holidayName;
  final bool isDeleted;
  final String? zoneId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveData({
    required this.id,
    required this.holidayType,
    required this.holidayDate,
    required this.holidayName,
    required this.isDeleted,
    this.zoneId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      id: json['id'] ?? '',
      holidayType: json['holiday_type'] ?? '',
      holidayDate: DateTime.parse(json['holiday_date']),
      holidayName: json['holiday_name'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      zoneId: json['zone_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'holiday_type': holidayType,
    'holiday_date': holidayDate.toIso8601String(),
    'holiday_name': holidayName,
    'is_deleted': isDeleted,
    'zone_id': zoneId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// ------------------------
/// HELPER FUNCTIONS
/// ------------------------
LeaveCalendarResponse leaveCalendarResponseFromJson(String str) =>
    LeaveCalendarResponse.fromJson(json.decode(str));

String leaveCalendarResponseToJson(LeaveCalendarResponse data) =>
    json.encode(data.toJson());
