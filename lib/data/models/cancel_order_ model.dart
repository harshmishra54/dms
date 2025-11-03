class CancelUpdateOrderRequest {
  final String id; // order_id
  final String roleId;
  final String requestId;
  final List<CancelProduct> products;
  final bool? cancel;

  CancelUpdateOrderRequest({
    required this.id,
    required this.roleId,
    required this.requestId,
    required this.products,
    this.cancel,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "role_id": roleId,
      "request_id": requestId,
      "products": products.map((p) => p.toJson()).toList(),
      "cancel": cancel == true ? true : null,
    };
  }
}

class CancelProduct {
  final String productId;
  final int quantity;

  CancelProduct({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "quantity": quantity,
    };
  }
}

class CancelUpdateOrderResponse {
  final int success;
  final String message;

  CancelUpdateOrderResponse({
    required this.success,
    required this.message,
  });

  factory CancelUpdateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CancelUpdateOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
