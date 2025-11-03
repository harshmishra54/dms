// ipt_order_update_model.dart
class IptOrderUpdateRequest {
  final String orderId;
  final String status;

  IptOrderUpdateRequest({
    required this.orderId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'status': status,
    };
  }
}

class IptOrderUpdateResponse {
  final int success;
  final String message;

  IptOrderUpdateResponse({
    required this.success,
    required this.message,
  });

  factory IptOrderUpdateResponse.fromJson(Map<String, dynamic> json) {
    return IptOrderUpdateResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
