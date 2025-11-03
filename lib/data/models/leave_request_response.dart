class LeaveRequestResponse {
  final int success;
  final String message;

  LeaveRequestResponse({
    required this.success,
    required this.message,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
