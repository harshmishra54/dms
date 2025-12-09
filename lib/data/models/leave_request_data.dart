class LeaveRequestData {
  final String startDate;
  final String endDate;
  final String roleId;
  final String requestId;
  final String reason;
  final int leaveType;
  final String? Startperiod;
  final String? endPeriod;

  LeaveRequestData({
    required this.startDate,
    required this.endDate,
    required this.roleId,
    required this.requestId,
    required this.reason,
    required this.leaveType,
    this.Startperiod,
    this.endPeriod,
  });

  Map<String, dynamic> toJson() => {
    "start_date": startDate,
    "end_date": endDate,
    "role_id": roleId,
    "request_id": requestId,
    "reason": reason,
    "leave_type": leaveType,
    "start_period": Startperiod,
    "end_period": endPeriod,
  };
}
