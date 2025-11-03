class LeaveManagementResponse {
  final int success;
  final String message;
  final List<LeaveManagementData> data;

  LeaveManagementResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LeaveManagementResponse.fromJson(Map<String, dynamic> json) {
    return LeaveManagementResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<LeaveManagementData>.from(
          json['data'].map((x) => LeaveManagementData.fromJson(x)))
          : [],
    );
  }
}

class LeaveManagementData {
  final String startDate;
  final String endDate;
  final String status;
  final int leaveType;
  final String reason;

  LeaveManagementData({
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.leaveType,
    required this.reason,
  });

  factory LeaveManagementData.fromJson(Map<String, dynamic> json) {
    return LeaveManagementData(
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      status: json['status'] ?? '',
      leaveType: json['leave_type'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }
}
