// lib/data/models/verify_otp_response.dart
class VerifyOtpResponse {
  final int success;
  final bool userflag;
  final String data;
  final String message;

  VerifyOtpResponse({
    required this.success,
    required this.userflag,
    required this.data,
    required this.message,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'],
      userflag: json['user_flag'] ?? '',
      data: json['data'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
