// tsi_approve_return_models.dart

// Request Model
class TsiApproveReturnClaimRequest {
  final String id;
  final String requestId;
  final String roleId;
  final int decision;

  TsiApproveReturnClaimRequest({
    required this.id,
    required this.requestId,
    required this.roleId,
    required this.decision,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "request_id": requestId,
      "role_id": roleId,
      "decision": decision,
    };
  }
}

// Response Model
class TsiApproveReturnOrderResponse {
  final int success;
  final String message;

  TsiApproveReturnOrderResponse({
    required this.success,
    required this.message,
  });

  factory TsiApproveReturnOrderResponse.fromJson(Map<String, dynamic> json) {
    return TsiApproveReturnOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? "",
    );
  }
}
