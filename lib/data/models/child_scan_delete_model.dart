// scan_delete_models.dart

class ScanDeleteResponse {
  final int success;
  final String message;
  final ScanDeleteData? data;

  ScanDeleteResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ScanDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ScanDeleteResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null
          ? ScanDeleteData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class ScanDeleteData {
  final String? uniqueCode;
  final String? sku;
  final String? batchNo;
  final String? orderQty;
  final String? qty;

  ScanDeleteData({
    this.uniqueCode,
    this.sku,
    this.batchNo,
    this.orderQty,
    this.qty,
  });

  factory ScanDeleteData.fromJson(Map<String, dynamic> json) {
    return ScanDeleteData(
      uniqueCode: json['uniqueCode'],
      sku: json['sku'],
      batchNo: json['batchNo'],
      orderQty: json['orderQty'],
      qty: json['qty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uniqueCode": uniqueCode,
      "sku": sku,
      "batchNo": batchNo,
      "orderQty": orderQty,
      "qty": qty,
    };
  }
}

class ScanDeleteCodePostData {
  final String? orderId;
  final String? uniqueCode;

  ScanDeleteCodePostData({
    this.orderId,
    this.uniqueCode,
  });

  factory ScanDeleteCodePostData.fromJson(Map<String, dynamic> json) {
    return ScanDeleteCodePostData(
      orderId: json['orderId'],
      uniqueCode: json['uniqueCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "uniqueCode": uniqueCode,
    };
  }
}
