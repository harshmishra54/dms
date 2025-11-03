/// ✅ Request Model
class RsmApproveUpdateOrderModelRequest {
  final String status;
  final String roleId;
  final String orderId;
  final String requestId;

  RsmApproveUpdateOrderModelRequest({
    required this.status,
    required this.roleId,
    required this.orderId,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "role_id": roleId,
      "order_id": orderId,
      "request_id": requestId,
    };
  }
}

/// ✅ Response Model
class UpdateOrderByRSMResponse {
  final int success;
  final String message;

  UpdateOrderByRSMResponse({
    required this.success,
    required this.message,
  });

  factory UpdateOrderByRSMResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOrderByRSMResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
    );
  }
}
