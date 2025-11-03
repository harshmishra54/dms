class UpdateLeaveStatusRequest {
  final String id;
  final String status;

  UpdateLeaveStatusRequest({
    required this.id,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
class UpdateLeaveStatusResponse {
  final int success;
  final String message;
  final LeaveData? data;

  UpdateLeaveStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateLeaveStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateLeaveStatusResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? LeaveData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class LeaveData {
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

  LeaveData({
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

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
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
