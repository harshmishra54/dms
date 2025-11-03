// 📂 add_return_claim_models.dart

class AddReturnClaimPostData {
  final String price;
  final int roleId;
  final int requestedRoleId;
  final int? qty;
  final String? createdBy;
  final String fromLocation;
  final String toLocation;
  final List<LineItems> lineItems;

  AddReturnClaimPostData({
    required this.price,
    required this.roleId,
    required this.requestedRoleId,
    this.qty,
    this.createdBy,
    required this.fromLocation,
    required this.toLocation,
    required this.lineItems,
  });

  Map<String, dynamic> toJson() {
    return {
      "price": price,
      "role_id": roleId,
      "requested_role_id": requestedRoleId,
      "qty": qty,
      "created_by": createdBy,
      "from_location": fromLocation,
      "to_location": toLocation,
      "lineItems": lineItems.map((x) => x.toJson()).toList(),
    };
  }
}

class LineItems {
  final String itemCode;
  final String qty;
  final String level;
  final String batchId;
  final String price;
  final String? reason;
  final String uniqueCode;

  LineItems({
    required this.itemCode,
    required this.qty,
    required this.level,
    required this.batchId,
    required this.price,
    this.reason,
    required this.uniqueCode,

  });

  Map<String, dynamic> toJson() {
    return {
      "itemCode": itemCode,
      "qty": qty,
      "level": level,
      "batch_id": batchId,
      "price": price,
      "unique_code": uniqueCode,
      if (reason != null && reason!.isNotEmpty) "reason": reason, // ✅ only include if set
    };
  }

  factory LineItems.fromJson(Map<String, dynamic> json) {
    return LineItems(
      itemCode: json["itemCode"] ?? "",
      qty: json["qty"] ?? "0",
      level: json["level"] ?? "",
      batchId: json["batch_id"] ?? "",
      price: json["price"] ?? "0",
      reason: json["reason"], // ✅ safe parse
      uniqueCode: json["unique_code"] ?? "",
    );
  }
}

class AddReturnClaimResponse {
  final int success;
  final String message;
  final String orderId;

  AddReturnClaimResponse({
    required this.success,
    required this.message,
    required this.orderId,
  });

  factory AddReturnClaimResponse.fromJson(Map<String, dynamic> json) {
    return AddReturnClaimResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      orderId: json["orderId"] ?? "",
    );
  }
}
