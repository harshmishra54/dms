class AcceptAllItemsModelRequest {
  final String orderId;

  AcceptAllItemsModelRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
    };
  }
}

class AcceptAllItemsModelResponse {
  final int success;
  final String message;

  AcceptAllItemsModelResponse({
    required this.success,
    required this.message,
  });

  factory AcceptAllItemsModelResponse.fromJson(Map<String, dynamic> json) {
    return AcceptAllItemsModelResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
    );
  }
}
