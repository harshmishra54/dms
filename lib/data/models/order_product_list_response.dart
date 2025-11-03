import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';

class OrderProductListResponse {
  final int success;
  final String message;
  final List<OrderProductListDataResponse> data;

  OrderProductListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderProductListResponse.fromJson(Map<String, dynamic> json) {
    return OrderProductListResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OrderProductListDataResponse.fromJson(item))
          .toList() ??
          [],
    );
  }
}
