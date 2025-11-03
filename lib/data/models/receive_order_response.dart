// receive_order_response.dart

class ReceiveOrderResponse {
  final int success;
  final String message;
  final List<OrderData> data;

  ReceiveOrderResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReceiveOrderResponse.fromJson(Map<String, dynamic> json) {
    return ReceiveOrderResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => OrderData.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
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
  final String price;
  final String orderDate;
  final String status;
  final String createdAt;
  final String uId;
  final String updatedAt;

  OrderData({
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

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      id: json['id'] ?? '',
      orderNo: json['order_no'],
      roleId: json['role_id'] ?? 0,
      createdBy: json['created_by'] ?? '',
      fromLocation: json['from_location'] ?? '',
      toLocation: json['to_location'] ?? '',
      qty: json['qty'] ?? '',
      price: json['price'] ?? '',
      orderDate: json['order_date'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      uId: json['u_id'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_no': orderNo,
      'role_id': roleId,
      'created_by': createdBy,
      'from_location': fromLocation,
      'to_location': toLocation,
      'qty': qty,
      'price': price,
      'order_date': orderDate,
      'status': status,
      'createdAt': createdAt,
      'u_id': uId,
      'updatedAt': updatedAt,
    };
  }
}
