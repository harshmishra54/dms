class CreditUpdateRequest {
  final String roleId;
  final String requestId;
  final double requestedLimit;
  final String reason;
  final double? current_limit;


  CreditUpdateRequest({
    required this.roleId,
    required this.requestId,
    required this.requestedLimit,
    required this.reason,
    this.current_limit,

  });

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'request_id': requestId,
      'requested_limit': requestedLimit,
      'reason': reason,
      'current_limit':current_limit,
    };
  }

  factory CreditUpdateRequest.fromJson(Map<String, dynamic> json) {
    return CreditUpdateRequest(
      roleId: json['role_id'] ?? '',
      requestId: json['request_id'] ?? '',
      requestedLimit: (json['requested_limit'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      current_limit: (json['current_limit'] ?? 0).toDouble(),
    );
  }
}

class CreditUpdateResponse {
  final int success;
  final String message;

  CreditUpdateResponse({
    required this.success,
    required this.message,
  });

  factory CreditUpdateResponse.fromJson(Map<String, dynamic> json) {
    return CreditUpdateResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
