// lib/data/models/punchout_model.dart

class PunchOutRequest {
  final String userId;
  final String conclusion;

  PunchOutRequest({
    required this.userId,
    required this.conclusion,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "conclusion": conclusion,
    };
  }
}

class PunchOutResponse {
  final int success;
  final String message;

  PunchOutResponse({
    required this.success,
    required this.message,
  });

  factory PunchOutResponse.fromJson(Map<String, dynamic> json) {
    return PunchOutResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
