class RouteDetailsResponseData {
  final int success;
  final String message;
  final RouteDetails data;

  RouteDetailsResponseData({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RouteDetailsResponseData.fromJson(Map<String, dynamic> json) {
    return RouteDetailsResponseData(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: RouteDetails.fromJson(json['data']),
    );
  }
}

class RouteDetails {
  final String id;
  final String name;
  final String firmName;
  final String mobileNo;
  final String orderId;
  final String returnOrderId;
  final String status;
  final double oldInventoryStock;
  final double pendingAmount;
  final double totalCredit;
  final String comment;
  final double lat;
  final double long;

  RouteDetails({
    required this.id,
    required this.name,
    required this.firmName,
    required this.mobileNo,
    required this.orderId,
    required this.returnOrderId,
    required this.status,
    required this.oldInventoryStock,
    required this.pendingAmount,
    required this.totalCredit,
    required this.comment,
    required this.lat,
    required this.long,
  });

  // Helper method to safely parse dynamic values to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory RouteDetails.fromJson(Map<String, dynamic> json) {
    return RouteDetails(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      firmName: json['firm_name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
      orderId: json['order_id'] ?? '',
      returnOrderId: json['return_order_id'] ?? '',
      status: json['status'] ?? '',
      oldInventoryStock: _parseDouble(json['old_inventory_stock']),
      pendingAmount: _parseDouble(json['pending_amount']),
      totalCredit: _parseDouble(json['total_credit']),
      comment: json['comment'] ?? '',
      lat: _parseDouble(json['lat']),
      long: _parseDouble(json['long']),
    );
  }
}
