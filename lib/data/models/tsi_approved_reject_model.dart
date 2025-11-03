// Request Model
class OrderTsiApproveRequest {
  final String roleId;
  final String requestId;
  final String orderId;
  final int decision;
  final String? reason;

  OrderTsiApproveRequest({
    required this.roleId,
    required this.requestId,
    required this.orderId,
    required this.decision,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'request_id': requestId,
      'order_id': orderId,
      'decision': decision,
      if (reason != null) "reason": reason,
    };
  }
}

// Response Model
class TsiApproveOrderResponse {
  final int success;
  final String message;

  TsiApproveOrderResponse({
    required this.success,
    required this.message,
  });

  factory TsiApproveOrderResponse.fromJson(Map<String, dynamic> json) {
    return TsiApproveOrderResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}
