class InwardPreview {
  final int success;
  final String message;
  final OrderDetails? data;

  InwardPreview({
    required this.success,
    required this.message,
    this.data,
  });

  factory InwardPreview.fromJson(Map<String, dynamic> json) {
    return InwardPreview(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderDetails.fromJson(json['data']) : null,
    );
  }
}

class OrderDetails {
  final String orderId;
  final String toId;       // 👈 instead of mapping to customerName
  final String orderNo;    // 👈 add this
  final String status;
  final String totalQty;
  final List<OrderItem> items;

  OrderDetails({
    required this.orderId,
    required this.toId,
    required this.orderNo,
    required this.status,
    required this.totalQty,
    required this.items,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderId: json['orderId'] ?? '',
      toId: json['toId'] ?? '',        // 👈 maps correctly
      orderNo: json['orderNo'] ?? '',  // 👈 maps correctly
      status: json['status'] ?? '',
      totalQty: json['totalQty'] ?? '',
      items: (json['list'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderItem {
  final String orderDetailsId;
  final String sku;
  final String name;
  final String batchNo;
  final String batchId;
  final String outwardQty;
  final String inwardQty;
  final String missingQty;
  final String excessQty;
  final String totalQty;

  OrderItem({
    required this.orderDetailsId,
    required this.sku,
    required this.name,
    required this.batchNo,
    required this.outwardQty,
    required this.inwardQty,
    required this.missingQty,
    required this.excessQty,
    required this.totalQty,
    required this.batchId
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderDetailsId: json['orderDetailsId'] ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      batchNo: json['batchNo'] ?? '',
      outwardQty: json['outwardQty'] ?? '',
      inwardQty: json['inwardQty'] ?? '',
      missingQty: json['missingQty'] ?? '',
      excessQty: json['excessQty'] ?? '',
      totalQty: json['totalQty'] ?? '',
      batchId: json['batchId'] ?? '',
    );
  }
}
