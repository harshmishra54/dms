// lib/data/models/complete_return_order_model.dart

class CompleteReturnOrderRequest {
  final String orderId;
  final int roleId;
  final String fromLocation;
  final String createdBy;
  final int requestedRoleId;
  final String reason;

  CompleteReturnOrderRequest({
    required this.orderId,
    required this.roleId,
    required this.fromLocation,
    required this.createdBy,
    required this.requestedRoleId,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "role_id": roleId,
      "from_location": fromLocation,
      "created_by": createdBy,
      "requested_role_id": requestedRoleId,
      "reason": reason,
    };
  }
}

class CompleteReturnOrderResponse {
  final int success;
  final String message;
  final String? returnOrderId;
  final String? originalOrderId;

  CompleteReturnOrderResponse({
    required this.success,
    required this.message,
    this.returnOrderId,
    this.originalOrderId,
  });

  factory CompleteReturnOrderResponse.fromJson(Map<String, dynamic> json) {
    return CompleteReturnOrderResponse(
      success: json["success"] is int
          ? json["success"]
          : int.tryParse(json["success"].toString()) ?? 0,
      message: json["message"] ?? '',
      returnOrderId: json["returnOrderId"],
      originalOrderId: json["originalOrderId"],
    );
  }

}
