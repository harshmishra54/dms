// inward_scan_details_model.dart

class InwardScanDetails {
  final String orderId;
  final String orderDetailsId;
  final int type;

  InwardScanDetails({
    required this.orderId,
    required this.orderDetailsId,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "orderDetailsId": orderDetailsId,
      "type": type,
    };
  }
}

class InwardScanDetailsResponse {
  final int success;
  final String message;
  final InwardScanData? data;

  InwardScanDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory InwardScanDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InwardScanDetailsResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? InwardScanData.fromJson(json['data'])
          : null,
    );
  }
}

class InwardScanData {
  final String fromId;
  final String toId;
  final String orderDate;
  final String orderNo;
  final String status;
  final String sku;
  final String batchNo;
  final String scanned;
  final List<InwardItem>? list;

  InwardScanData({
    required this.fromId,
    required this.toId,
    required this.orderDate,
    required this.orderNo,
    required this.status,
    required this.sku,
    required this.batchNo,
    required this.scanned,
    this.list,
  });

  factory InwardScanData.fromJson(Map<String, dynamic> json) {
    return InwardScanData(
      fromId: json['fromId'] ?? '',
      toId: json['toId'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderNo: json['orderNo'] ?? '',
      status: json['status'] ?? '',
      sku: json['sku'] ?? '',
      batchNo: json['batchNo'] ?? '',
      scanned: json['scanned'] ?? '',
      list: json['list'] != null
          ? (json['list'] as List)
          .map((item) => InwardItem.fromJson(item))
          .toList()
          : [],
    );
  }
}

class InwardItem {
  final String id;
  final String uniqueCode;
  final String level;

  InwardItem({
    required this.id,
    required this.uniqueCode,
    required this.level,
  });

  factory InwardItem.fromJson(Map<String, dynamic> json) {
    return InwardItem(
      id: json['id'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      level: json['level'] ?? '',
    );
  }
}
