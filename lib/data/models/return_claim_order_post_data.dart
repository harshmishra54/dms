// models/return_claim_order_post_data.dart
class ReturnClaimOrderPostData {
  final String status;
  final String orderId;
  final String requestId;

  ReturnClaimOrderPostData({
    required this.status,
    required this.orderId,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'order_id': orderId,
      'request_id': requestId,
    };
  }
}

// models/return_claim_order_response.dart
class ReturnClaimOrderResponse {
  final int success;
  final String message;

  ReturnClaimOrderResponse({
    required this.success,
    required this.message,
  });

  factory ReturnClaimOrderResponse.fromJson(Map<String, dynamic> json) {
    return ReturnClaimOrderResponse(
      success: json['success'],
      message: json['message'],
    );
  }
}
