// tsi_order_model.dart
class TsiOrderRequest {
  final String tsmId;

  TsiOrderRequest({required this.tsmId});

  Map<String, dynamic> toJson() {
    return {
      "tsm_id": tsmId,
    };
  }
}

class OrderResponse {
  final int success;
  final String message;
  final List<RetailerOrder> retailerOrders;
  final List<DistributorOrder> distributorOrders;


  OrderResponse({
    required this.success,
    required this.message,
    required this.distributorOrders,
    required this.retailerOrders,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      success: json['success'],
      message: json['message'],
      distributorOrders: (json['distributorOrders'] as List)
          .map((e) => DistributorOrder.fromJson(e))
          .toList(),
      retailerOrders: (json['retailerOrders'] as List)
          .map((e) => RetailerOrder.fromJson(e))
          .toList(),
    );
  }
}

class DistributorOrder {
  final String id;
  final String orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String qty;
  final String? isReorder;
  final String price;
  final String orderDate;
  final String deliveryDate;
  final String gst;
  final String? schemePoints;
  final String discountPrice;
  final String status;
  final String createdAt;
  final String uId;
  final String updatedAt;
  final String isApprove;
  final String fromLocationName;
  final String toLocationName;

  DistributorOrder({
    required this.id,
    required this.orderNo,
    required this.roleId,
    required this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.qty,
    this.isReorder,
    required this.price,
    required this.orderDate,
    required this.deliveryDate,
    required this.gst,
    this.schemePoints,
    required this.discountPrice,
    required this.status,
    required this.createdAt,
    required this.uId,
    required this.updatedAt,
    required this.isApprove,
    required this.fromLocationName,
    required this.toLocationName,
  });

  factory DistributorOrder.fromJson(Map<String, dynamic> json) {
    return DistributorOrder(
      id: json['id'],
      orderNo: json['order_no'],
      roleId: json['role_id'],
      createdBy: json['created_by'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      qty: json['qty'],
      isReorder: json['is_reorder'],
      price: json['price'],
      orderDate: json['order_date'],
      deliveryDate: json['delivery_date'],
      gst: json['gst'],
      schemePoints: json['scheme_points'],
      discountPrice: json['discount_price'],
      status: json['status'],
      createdAt: json['createdAt'],
      uId: json['u_id'],
      updatedAt: json['updatedAt'],
      isApprove: json['is_approve'],
      fromLocationName: json['from_location_name'],
      toLocationName: json['to_location_name'],
    );
  }
}

class RetailerOrder {
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
  final String? isReorder;
  final String? schemePoints;
  final String discountPrice;
  final String status;
  final String createdAt;
  final String uId;
  final String updatedAt;
  final String isApprove;
  final String? fromLocationName;
  final String toLocationName;

  RetailerOrder({
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
    required this.toLocationName,
  });

  factory RetailerOrder.fromJson(Map<String, dynamic> json) {
    return RetailerOrder(
      id: json['id'],
      orderNo: json['order_no'],
      roleId: json['role_id'],
      createdBy: json['created_by'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      qty: json['qty'],
      price: json['price'],
      orderDate: json['order_date'],
      deliveryDate: json['delivery_date'],
      gst: json['gst'],
      isReorder: json['is_reorder'],
      schemePoints: json['scheme_points'],
      discountPrice: json['discount_price'],
      status: json['status'],
      createdAt: json['createdAt'],
      uId: json['u_id'],
      updatedAt: json['updatedAt'],
      isApprove: json['is_approve'],
      fromLocationName: json['from_location_name'],
      toLocationName: json['to_location_name'],
    );
  }
}
