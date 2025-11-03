class ReceiveReturnClaimPostData {
  final String roleId;
  final String requestId;

  ReceiveReturnClaimPostData({
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
class ReceiveReturnClaimResponse {
  final int success;
  final List<AcceptOrderData> data;

  ReceiveReturnClaimResponse({
    required this.success,
    required this.data,
  });

  factory ReceiveReturnClaimResponse.fromJson(Map<String, dynamic> json) {
    return ReceiveReturnClaimResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => AcceptOrderData.fromJson(item))
          .toList() ??
          [],
    );
  }
}

class AcceptOrderData {
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

  AcceptOrderData({
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

  factory AcceptOrderData.fromJson(Map<String, dynamic> json) {
    return AcceptOrderData(
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
