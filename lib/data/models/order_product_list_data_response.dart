class OrderProductListDataResponse {
  final String id;          // ✅ Add this
  final String itemCode;
  final String productName;
  final double price;
  final double schemePrice;
  final double purchasePrice;
  final String distributorId;

  OrderProductListDataResponse({
    required this.id,       // ✅ include in constructor
    required this.itemCode,
    required this.productName,
    required this.price,
    required this.schemePrice,
    required this.purchasePrice,
    required this.distributorId,
  });

  factory OrderProductListDataResponse.fromJson(Map<String, dynamic> json) {
    return OrderProductListDataResponse(
      id: json['id'] ?? '', // ✅ parse UUID
      itemCode: json['item_code'] ?? '',
      productName: json['product_name'] ?? '',
      price: _toDouble(json['price']),
      schemePrice: _toDouble(json['scheme_price']),
      purchasePrice: _toDouble(json['purchase_price']),
      distributorId: json['distributor_id'] ?? '',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    // Used by DropdownSearch
    return productName;
  }
}
