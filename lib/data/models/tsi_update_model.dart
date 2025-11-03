// request model
import 'package:TrustTags_DMS/data/models/line_item.dart';

class UpdateOrderRequest {
  final String orderId;
  final String fromLocation;
  final List<LineItem> lineItems;

  UpdateOrderRequest({
    required this.orderId,
    required this.fromLocation,
    required this.lineItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'from_location': fromLocation,
      'lineItems': lineItems.map((e) => e.toJson()).toList(),
    };
  }
}

// response model
class UpdateOrderResponse {
  final int success;
  final String message;

  UpdateOrderResponse({
    required this.success,
    required this.message,
  });

  factory UpdateOrderResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
