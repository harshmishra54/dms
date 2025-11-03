import 'dart:convert';

/// ----------------------
/// Request Model
/// ----------------------
class OrderUpdateRequest {
  final String status;
  final String roleId;
  final String orderId;
  final String requestId;
  final String deliveryDate;
   // ✅ keep it nullable string

  OrderUpdateRequest({
    required this.status,
    required this.roleId,
    required this.orderId,
    required this.requestId,
    required this.deliveryDate,

  });

  Map<String, dynamic> toJson() {
    final data = {
      "status": status,
      "role_id": roleId,
      "order_id": orderId,
      "request_id": requestId,
      "delivery_date": deliveryDate,
    };

    // ✅ ensure it's always a string when sending


    return data;
  }
}

/// ----------------------
/// Response Model
/// ----------------------
class AddOrderResponses {
  final int success;
  final String response;
  final String message;
  final String orderId;

  AddOrderResponses({
    required this.success,
    required this.response,
    required this.message,
    required this.orderId,
  });

  factory AddOrderResponses.fromJson(Map<String, dynamic> json) {
    return AddOrderResponses(
      success: json["success"] ?? 0,
      response: json["response"] ?? "",
      message: json["message"] ?? "",
      orderId: json["orderId"] ?? "",
    );
  }

  static AddOrderResponses fromRawJson(String str) =>
      AddOrderResponses.fromJson(json.decode(str));
}
