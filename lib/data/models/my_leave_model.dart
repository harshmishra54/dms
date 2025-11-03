import 'dart:convert';

/// =====================
/// REQUEST MODEL
/// =====================
class MyLeaveRequest {
  final String id;

  MyLeaveRequest({required this.id});

  factory MyLeaveRequest.fromJson(Map<String, dynamic> json) {
    return MyLeaveRequest(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  static MyLeaveRequest fromRawJson(String str) =>
      MyLeaveRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// =====================
/// RESPONSE MODEL
/// =====================
class MyLeaveResponse {
  final int success;
  final String message;
  final List<MyLeave> data;

  MyLeaveResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MyLeaveResponse.fromJson(Map<String, dynamic> json) {
    return MyLeaveResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MyLeave.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  static MyLeaveResponse fromRawJson(String str) =>
      MyLeaveResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// =====================
/// LEAVE DATA MODEL
/// =====================
class MyLeave {
  final String id;
  final int roleId;
  final String locationId;
  final int leaveType;
  final String reason;
  final String startDate;
  final String endDate;
  final String startPeriod;
  final String endPeriod;
  final int totalDays;
  final String status;
  final String createdAt;
  final String updatedAt;

  MyLeave({
    required this.id,
    required this.roleId,
    required this.locationId,
    required this.leaveType,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.totalDays,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MyLeave.fromJson(Map<String, dynamic> json) {
    return MyLeave(
      id: json['id'] ?? '',
      roleId: json['role_id'] ?? 0,
      locationId: json['location_id'] ?? '',
      leaveType: json['leave_type'] ?? 0,
      reason: json['reason'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startPeriod: json['start_period'] ?? '',
      endPeriod: json['end_period'] ?? '',
      totalDays: json['total_days'] ?? 0,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role_id': roleId,
      'location_id': locationId,
      'leave_type': leaveType,
      'reason': reason,
      'start_date': startDate,
      'end_date': endDate,
      'start_period': startPeriod,
      'end_period': endPeriod,
      'total_days': totalDays,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
