class OrderDetailsResponse {
  final int success;
  final OrderData data;
  final String? message;
  final List<OrderDetail> detail;

  OrderDetailsResponse({
    required this.success,
    required this.data,
    this.message,
    required this.detail,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponse(
      success: json['success'],
      data: OrderData.fromJson(json['data']),
      message: json['message'],
      detail: (json['detail'] as List)
          .map((e) => OrderDetail.fromJson(e))
          .toList(),
    );
  }
}

class OrderData {
  final String id;
  final String? orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String qty;
  final String? isReorder; // nullable
  final String price;
  final String? deliveryDate; // nullable
  final String gst;
  final String discountPrice;
  final String? purchasePrice;
  final String? schemePoints; // nullable
  final String orderDate;
  final String status;
  final String createdAt;
  final String uId;
  final String updatedAt;
  final String? isApprove; // nullable

  OrderData({
    required this.id,
    this.orderNo,
    required this.roleId,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.qty,
    this.isReorder,
    required this.price,
    this.purchasePrice,
    this.deliveryDate,
    required this.gst,
    required this.discountPrice,
    this.schemePoints,
    required this.orderDate,
    required this.status,
    required this.createdAt,
    required this.uId,
    required this.updatedAt,
    this.isApprove,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'],
      orderNo: json['order_no'],
      roleId: json['role_id'],
      createdBy: json['created_by'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      qty: json['qty'].toString(),
      isReorder: json['is_reorder']?.toString(),       // convert bool to String
      price: json['price'].toString(),
      deliveryDate: json['delivery_date']?.toString(),
      gst: json['gst'].toString(),
      discountPrice: json['discount_price'].toString(),
      schemePoints: json['scheme_points']?.toString(),
      orderDate: json['order_date'],
      status: json['status'],
      createdAt: json['createdAt'],
      uId: json['u_id'],
      updatedAt: json['updatedAt'],
      isApprove: json['is_approve']?.toString(),      // convert bool to String
      purchasePrice: json['purchase_price']?.toString(),
    );
  }

}

class OrderDetail {
  final String id;
  final String orderId;
  final String productId;
  final String? level;
  final String? batchId;
  final String qty;
  final String? schemePrice;
  final String ? purchasePrice;
  final String price;
  final ProductData product;
  final String createdAt;
  final String updatedAt;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.productId,
    this.level,
    this.batchId,
    required this.qty,
    this.schemePrice,
    required this.price,
    this.purchasePrice,
    required this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      level: json['level'],
      batchId: json['batch_id'],
      qty: json['qty'],
      schemePrice: json['scheme_price'],
      price: json['price'],
      purchasePrice: json['purchase_price'],
      product: ProductData.fromJson(json['product']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ProductData {
  final String id;
  final String name;

  ProductData({required this.id, required this.name});

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json['id'],
      name: json['name'],
    );
  }
}
