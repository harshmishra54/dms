// reorder_request.dart
class ReorderRequest {
  final String orderId;
  final int roleId;
  final String fromLocation;
  final String createdBy;
  final int requestedRoleId;

  ReorderRequest({
    required this.orderId,
    required this.roleId,
    required this.fromLocation,
    required this.createdBy,
    required this.requestedRoleId,
  });

  Map<String, dynamic> toJson() {
    return {
      "order_id": orderId,
      "role_id": roleId,
      "from_location": fromLocation,
      "created_by": createdBy,
      "requested_role_id": requestedRoleId,
    };
  }
}
// reorder_response.dart
class ReorderResponse {
  final int success;
  final String message;
  final String newOrderId;
  final String oldOrderId;
  final String newOrderNo;

  ReorderResponse({
    required this.success,
    required this.message,
    required this.newOrderId,
    required this.oldOrderId,
    required this.newOrderNo,
  });

  factory ReorderResponse.fromJson(Map<String, dynamic> json) {
    return ReorderResponse(
      success: json['success'],
      message: json['message'],
      newOrderId: json['newOrderId'],
      oldOrderId: json['oldOrderId'],
      newOrderNo: json['newOrderNo'],
    );
  }
}
