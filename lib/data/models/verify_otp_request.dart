// lib/data/models/verify_otp_request.dart
class VerifyOtpRequest {
  final String? verificationKey;
  final String? otp;
  final String? phone;
  final String countryCode;
  final int userType;
  final String name;
  final String? sessionId;
  final String? registrationId;
  final String? fcmToken;

  VerifyOtpRequest({
    this.verificationKey,
    this.otp,
    this.phone,
    this.countryCode = "+91",
    required this.userType,
    this.name = "",
    this.sessionId,
    this.registrationId,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      "verification_key": verificationKey,
      "otp": otp,
      "phone": phone,
      "country_code": countryCode,
      "user_type": userType,
      "name": name,
      "sessionId": sessionId,
      "registrationId": registrationId,
      "fcm_token": fcmToken,
    };
  }
}
