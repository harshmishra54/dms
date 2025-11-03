class OrderListRequest {
  final String roleId;
  final String requestId;

  OrderListRequest({required this.roleId, required this.requestId});

  Map<String, dynamic> toJson() => {
    "role_id": roleId,
    "request_id": requestId,
  };
}

class OrderListResponse {
  final int success;
  final String response;
  final String message;
  final List<OrderListDataResponse> data;

  OrderListResponse({
    required this.success,
    required this.response,
    required this.message,
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    return OrderListResponse(
      success: json['success'] ?? 0,
      response: json['response'] ?? '',
      message: json['message'] ?? '',
      data: List<OrderListDataResponse>.from(
        (json['data'] as List<dynamic>? ?? [])
            .map((x) => OrderListDataResponse.fromJson(x)),
      ),
    );
  }
}

class OrderListDataResponse {
  final String id;
  final String orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final double qty;
  final double price;
  final String orderDate;
  final String status;
  final String deliveryDate;
  final double gst;
  final bool isReorder;
  final double schemePoints;
  final double discountPrice;
  final String? expectedDate;
  final String? isApprove;


  OrderListDataResponse({
    required this.id,
    required this.orderNo,
    required this.roleId,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.qty,
    required this.price,
    required this.orderDate,
    required this.status,
    required this.deliveryDate,
    required this.gst,
    required this.isReorder,
    required this.schemePoints,
    required this.discountPrice,
    this.expectedDate,
    this.isApprove,

  });

  factory OrderListDataResponse.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      if (value is int) return value == 1;
      return false;
    }

    return OrderListDataResponse(
      id: json['id'] ?? '',
      orderNo: json['order_no'] ?? '',
      roleId: int.tryParse(json['role_id'].toString()) ?? 0,
      createdBy: json['created_by'] ?? '',
      fromLocation: json['from_location'] ?? '',
      toLocation: json['to_location'] ?? '',
      qty: parseDouble(json['qty']),
      price: parseDouble(json['price']),
      orderDate: json['order_date'] ?? '',
      status: json['status'] ?? '',
      deliveryDate: json['delivery_date'] ?? '', // ✅ empty string instead of null
      gst: parseDouble(json['gst']),
      isReorder: parseBool(json['is_reorder']),  // ✅ false if null
      schemePoints: parseDouble(json['scheme_points']), // ✅ 0.0 if null
      discountPrice: parseDouble(json['discount_price']),
      expectedDate: json['expected_date'] ?? '',
      isApprove: json['is_approve'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_no": orderNo,
    "role_id": roleId,
    "created_by": createdBy,
    "from_location": fromLocation,
    "to_location": toLocation,
    "qty": qty,
    "price": price,
    "order_date": orderDate,
    "status": status,
    "delivery_date": deliveryDate,
    "gst": gst,
    "is_reorder": isReorder,
    "scheme_points": schemePoints,
    "discount_price": discountPrice,
    "expected_date": expectedDate,
    "is_approve": isApprove,
  };
}
