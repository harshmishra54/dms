// lib/data/models/return_order_details_model.dart

class DetailsOrderListResponse {
  final int success;
  final OrderDetailsData? data;
  final String message;
  final List<OrderDetailAdapterData>? detail;

  DetailsOrderListResponse({
    required this.success,
    this.data,
    required this.message,
    this.detail,
  });

  factory DetailsOrderListResponse.fromJson(Map<String, dynamic> json) {
    return DetailsOrderListResponse(
      success: json['success'] ?? 0,
      data: json['data'] != null
          ? OrderDetailsData.fromJson(json['data'])
          : null,
      message: json['message'] ?? "",
      detail: json['detail'] != null
          ? (json['detail'] as List)
          .map((e) => OrderDetailAdapterData.fromJson(e))
          .toList()
          : [],
    );
  }
}

class OrderDetailsData {
  final String id;
  final String? orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String qty;
  final String price;
  final String orderDate;
  final String status;
  final String createdAt;
  final String uId;
  final String updatedAt;

  OrderDetailsData({
    required this.id,
    this.orderNo,
    required this.roleId,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.qty,
    required this.price,
    required this.orderDate,
    required this.status,
    required this.createdAt,
    required this.uId,
    required this.updatedAt,
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    return OrderDetailsData(
      id: json['id'] ?? "",
      orderNo: json['order_no'],
      roleId: json['role_id'] ?? 0,
      createdBy: json['created_by'] ?? "",
      fromLocation: json['from_location'] ?? "",
      toLocation: json['to_location'] ?? "",
      qty: json['qty'] ?? "",
      price: json['price'] ?? "",
      orderDate: json['order_date'] ?? "",
      status: json['status'] ?? "",
      createdAt: json['createdAt'] ?? "",
      uId: json['u_id'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}

class OrderDetailAdapterData {
  final String id;
  final String orderId;
  final String productId;
  final String? level;
  final String? batchId;
  final String qty;
  final String reason;
  final String price;
  final ProductData product;
  final String createdAt;
  final String updatedAt;

  OrderDetailAdapterData({
    required this.id,
    required this.orderId,
    required this.productId,
    this.level,
    this.batchId,
    required this.qty,
    required this.reason,
    required this.price,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailAdapterData.fromJson(Map<String, dynamic> json) {
    return OrderDetailAdapterData(
      id: json['id'] ?? "",
      orderId: json['order_id'] ?? "",
      productId: json['product_id'] ?? "",
      level: json['level'],
      batchId: json['batch_id'],
      qty: json['qty'] ?? "",
      reason: json['reasone'] ?? "", // notice spelling from backend
      price: json['price'] ?? "",
      product: ProductData.fromJson(json['product']),
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}

class ProductData {
  final String id;
  final String name;

  ProductData({
    required this.id,
    required this.name,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
    );
  }
}
