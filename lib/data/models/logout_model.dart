// file: logout_model.dart

/// Request model
class LogoutRequest {
  final String roleId;
  final String id;

  LogoutRequest({
    required this.roleId,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'id': id,
    };
  }
}

/// Response model
class LogoutResponse {
  final int success;
  final String message;

  LogoutResponse({
    required this.success,
    required this.message,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
