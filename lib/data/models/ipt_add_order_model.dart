
// file: lib/data/models/ipt_add_order_model.dart

class AddIPTOrderRequest {
  final String fromLocation;
  final String toLocation;
  final List<IPTLineItem> lineItems;

  AddIPTOrderRequest({
    required this.fromLocation,
    required this.toLocation,
    required this.lineItems,
  });

  Map<String, dynamic> toJson() {
    return {
      "from_location": fromLocation,
      "to_location": toLocation,
      "lineItems": lineItems.map((e) => e.toJson()).toList(),
    };
  }
}

class IPTLineItem {
  final String itemCode;
  final int qty;
  final String level;
  final String batchId;
  final double price;
  final String? reason;
  final String uniqueCode;
  final String? storagebinId;

  IPTLineItem({
    required this.itemCode,
    required this.qty,
    required this.level,
    required this.batchId,
    required this.price,
    this.reason,
    required this.uniqueCode,
    this.storagebinId,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemCode": itemCode,
      "qty": qty,
      "level": level,
      "batchId": batchId,
      "price": price,
      "reason": reason,
      "uniqueCode": uniqueCode,
      "storage_bin_id": storagebinId,
    };
  }
}

// file: lib/data/models/add_return_claim_response.dart
class AddIPTResponse {
  final int success;
  final String message;
  final String orderId;

  AddIPTResponse({
    required this.success,
    required this.message,
    required this.orderId,
  });

  factory AddIPTResponse.fromJson(Map<String, dynamic> json) {
    return AddIPTResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? "",
      orderId: json["orderId"] ?? "",
    );
  }
}

