class DiscardAllItemsRequest {
  final String orderId;

  DiscardAllItemsRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
    };
  }
}

class DiscardAllItemsResponse {
  final int success;
  final String message;

  DiscardAllItemsResponse({
    required this.success,
    required this.message,
  });

  factory DiscardAllItemsResponse.fromJson(Map<String, dynamic> json) {
    return DiscardAllItemsResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
    );
  }
}
