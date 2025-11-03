class SendOtpResponse {
  final int success;
  final String? data; // ✅ It's a string, not a map
  final int? attempt;
  final SessionData? sessionData;
  final String? message;

  SendOtpResponse({
    required this.success,
    this.data,
    this.attempt,
    this.sessionData,
    this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      success: json['success'] ?? 0,
      data: json['data'], // ✅ No `.fromJson` here, just a string
      attempt: json['attempt'],
      message: json['message'],
      sessionData: json['sessionData'] != null
          ? SessionData.fromJson(json['sessionData'])
          : null,
    );
  }
}

class SessionData {
  final String? sessionId;
  final String? registrationId;

  SessionData({this.sessionId, this.registrationId});

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      sessionId: json['sessionId'],
      registrationId: json['registrationId'],
    );
  }
}
