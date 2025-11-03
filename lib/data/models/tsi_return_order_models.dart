// lib/data/models/tsi_return_order_models.dart

class TsiReturnOrderRequest {
  final String roleId;
  final String requestId;

  TsiReturnOrderRequest({
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

class TsiReturnOrderList {
  final int success;
  final String message;
  final List<TsiReturnOrderItem> data;

  TsiReturnOrderList({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TsiReturnOrderList.fromJson(Map<String, dynamic> json) {
    return TsiReturnOrderList(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List<dynamic>?)
          ?.map((e) => TsiReturnOrderItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class TsiReturnOrderItem {
  final String id;
  final String orderNo;
  final int roleId;
  final String createdBy;
  final String fromLocation;
  final String toLocation;
  final String qty;
  final String price;
  final String orderDate;
  String status; // mutable because we may update in UI
  final String? reason;
  final String isApprove;
  final String createdAt;
  final String uId;
  final String updatedAt;
  final String? fromLocationName;
  final String toLocationName;

  TsiReturnOrderItem({
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
    this.reason,
    required this.isApprove,
    required this.createdAt,
    required this.uId,
    required this.updatedAt,
    this.fromLocationName,
    required this.toLocationName,
  });

  factory TsiReturnOrderItem.fromJson(Map<String, dynamic> json) {
    return TsiReturnOrderItem(
      id: json["id"] ?? "",
      orderNo: json["order_no"] ?? "",
      roleId: json["role_id"] is int
          ? json["role_id"]
          : int.tryParse(json["role_id"].toString()) ?? 0,
      createdBy: json["created_by"] ?? "",
      fromLocation: json["from_location"] ?? "",
      toLocation: json["to_location"] ?? "",
      qty: json["qty"] ?? "",
      price: json["price"] ?? "",
      orderDate: json["order_date"] ?? "",
      status: json["status"] ?? "",
      reason: json["reason"],
      isApprove: json["is_approve"] ?? "",
      createdAt: json["createdAt"] ?? "",
      uId: json["u_id"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      fromLocationName: json["from_location_name"],
      toLocationName: json["to_location_name"] ?? "",
    );
  }
}
