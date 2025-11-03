// tsi_order_models.dart

class OrderTsiRequest {
  final String roleId;
  final String requestId;

  OrderTsiRequest({
    required this.roleId,
    required this.requestId,
  });

  Map<String, dynamic> toJson() {
    return {
      "role_id": roleId,
      "request_id": requestId,
    };
  }
}

class TsiOrderResponse {
  final int success;
  final List<OrderTsi> data;

  TsiOrderResponse({
    required this.success,
    required this.data,
  });

  factory TsiOrderResponse.fromJson(Map<String, dynamic> json) {
    return TsiOrderResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OrderTsi.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class OrderTsi {
  final String id;
  final String orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String qty;
  final String price;
  final String orderDate;
  final String deliveryDate;
  final String gst;
  final bool? isReorder;
  final int? schemePoints;
  final String discountPrice;
  String status;
  final String createdAt;
  final String uId;
  final String updatedAt;
  final String isApprove;
  final String? fromLocationName;
  final String? toLocationName;

  OrderTsi({
    required this.id,
    required this.orderNo,
    required this.roleId,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.qty,
    required this.price,
    required this.orderDate,
    required this.deliveryDate,
    required this.gst,
    this.isReorder,
    this.schemePoints,
    required this.discountPrice,
    required this.status,
    required this.createdAt,
    required this.uId,
    required this.updatedAt,
    required this.isApprove,
    this.fromLocationName,
    this.toLocationName,
  });

  factory OrderTsi.fromJson(Map<String, dynamic> json) {
    return OrderTsi(
      id: json['id'] ?? '',
      orderNo: json['order_no'] ?? '',
      roleId: json['role_id'] ?? 0,
      createdBy: json['created_by'] ?? '',
      fromLocation: json['from_location'] ?? '',
      toLocation: json['to_location'] ?? '',
      qty: json['qty'] ?? '',
      price: json['price'] ?? '',
      orderDate: json['order_date'] ?? '',
      deliveryDate: json['delivery_date'] ?? '',
      gst: json['gst'] ?? '',
      isReorder: json['is_reorder'],
      schemePoints: json['scheme_points'],
      discountPrice: json['discount_price'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      uId: json['u_id'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isApprove: json['is_approve'] ?? '',
      fromLocationName: json['from_location_name'],
      toLocationName: json['to_location_name'],
    );
  }
}
