class RejectTsiOrderRequest {
  final String id;
  final String roleId;
  final String requestId;
  final String rejectionReason;

  RejectTsiOrderRequest({
    required this.id,
    required this.roleId,
    required this.requestId,
    required this.rejectionReason,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "role_id": roleId,
      "request_id": requestId,
      "rejection_reason": rejectionReason,
    };
  }
}
class RejectTsiOrderResponse {
  final int success;
  final String message;

  RejectTsiOrderResponse({
    required this.success,
    required this.message,
  });

  factory RejectTsiOrderResponse.fromJson(Map<String, dynamic> json) {
    return RejectTsiOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
