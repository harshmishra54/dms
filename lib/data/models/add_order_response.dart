class AddOrderResponse {
  final int success;
  final String response;
  final String message;
  final String orderId;

  AddOrderResponse({
    required this.success,
    required this.response,
    required this.message,
    required this.orderId,
  });

  factory AddOrderResponse.fromJson(Map<String, dynamic> json) {
    return AddOrderResponse(
      success: json['success'] ?? 0,
      response: json['response'] ?? '',
      message: json['message'] ?? '',
      orderId: json['orderId'] ?? '',
    );
  }
}
