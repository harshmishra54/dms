// Request Model
class PartialAcceptOrderRequest {
  final String orderId;
  final List<String> orderDetailsIds;

  PartialAcceptOrderRequest({
    required this.orderId,
    required this.orderDetailsIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "orderDetailsIds": orderDetailsIds,
    };
  }
}

// Response Model
class PartialAcceptOrderResponse {
  final int success;
  final String message;

  PartialAcceptOrderResponse({
    required this.success,
    required this.message,
  });

  factory PartialAcceptOrderResponse.fromJson(Map<String, dynamic> json) {
    return PartialAcceptOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
    };
  }
}
