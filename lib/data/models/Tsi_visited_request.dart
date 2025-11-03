class TsiVisitedRequest {
  final String dailyRouteId;
  final String locationId;
  final String? orderId;
  final String? returnOrderId;
  final double oldInventoryStock;
  final double pendingAmount;
  final double totalCredit;
  final String? comment;
  final double lat;
  final double long;
  final String photo; // <-- updated

  TsiVisitedRequest({
    required this.dailyRouteId,
    required this.locationId,
    this.orderId,
    this.returnOrderId,
    required this.oldInventoryStock,
    required this.pendingAmount,
    required this.totalCredit,
    this.comment,
    required this.lat,
    required this.long,
    required this.photo,
  });

  Map<String, dynamic> toJson() {
    return {
      'daily_route_id': dailyRouteId,
      'location_id': locationId,
      'order_id': orderId,
      'return_order_id': returnOrderId,
      'old_inventory_stock': oldInventoryStock,
      'pending_amount': pendingAmount,
      'total_credit': totalCredit,
      'comment': comment,
      'lat': lat,
      'long': long,
      'photo': photo, // <-- now supports multiple
    };
  }
}
