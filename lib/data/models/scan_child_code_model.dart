import 'dart:convert';

/// ----------- Scan Info Response -----------
class ScanInfoResponse {
  final int success;
  final String message;
  final ScanInfoData? data;

  ScanInfoResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ScanInfoResponse.fromJson(Map<String, dynamic> json) {
    return ScanInfoResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null ? ScanInfoData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }

  static ScanInfoResponse fromRawJson(String str) =>
      ScanInfoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

/// ----------- Scan Info Data -----------
class ScanInfoData {
  final String? uniqueCode;
  final String? sku;
  final String? batchNo;
  final String? orderQty;
  final String? qty;

  ScanInfoData({
    this.uniqueCode,
    this.sku,
    this.batchNo,
    this.orderQty,
    this.qty,
  });

  factory ScanInfoData.fromJson(Map<String, dynamic> json) {
    return ScanInfoData(
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

/// ----------- Scan Info Post Data -----------
class ScanInfoPostData {
  final String? orderId;
  final bool? addLoose;
  final String? uniqueCode;

  ScanInfoPostData({
    this.orderId,
    this.addLoose,
    this.uniqueCode,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "addLoose": addLoose,
      "uniqueCode": uniqueCode,
    };
  }
}

/// ----------- Submit Post Data -----------
class SubmitPostData {
  final String? orderId;
  final String? userName;

  SubmitPostData({this.orderId, this.userName});

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userName": userName,
    };
  }
}

/// ----------- Submit Response -----------
class SubmitResponse {
  final int success;
  final String message;

  SubmitResponse({
    required this.success,
    required this.message,
  });

  factory SubmitResponse.fromJson(Map<String, dynamic> json) {
    return SubmitResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
    };
  }

  static SubmitResponse fromRawJson(String str) =>
      SubmitResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}
