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
  final int count;
  final int subordinateUsersCount;
  final List<MyLeave> data;

  MyLeaveResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.subordinateUsersCount,
    required this.data,
  });

  factory MyLeaveResponse.fromJson(Map<String, dynamic> json) {
    return MyLeaveResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      subordinateUsersCount: json['subordinate_users_count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MyLeave.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'count': count,
    'subordinate_users_count': subordinateUsersCount,
    'data': data.map((e) => e.toJson()).toList(),
  };
}


/// =====================
/// LEAVE DATA MODEL
/// =====================


class MyLeave {
  final String id;
  final String locationId;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;
  final String createdAt;
  final String userName;
  final String? userPhone;
  final int userRoleId;

  MyLeave({
    required this.id,
    required this.locationId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.userName,
    this.userPhone,
    required this.userRoleId,
  });

  factory MyLeave.fromJson(Map<String, dynamic> json) {
    return MyLeave(
      id: json['id'] ?? '',
      locationId: json['location_id'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      userName: json['user_name'] ?? '',
      userPhone: json['user_phone'],
      userRoleId: json['user_role_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'location_id': locationId,
    'start_date': startDate,
    'end_date': endDate,
    'reason': reason,
    'status': status,
    'createdAt': createdAt,
    'user_name': userName,
    'user_phone': userPhone,
    'user_role_id': userRoleId,
  };
}
