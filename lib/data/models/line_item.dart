class LineItem {
  final String itemCode;
  final String productName;
  int qty;
  final String schemePoints;
  final String batchId;
  final String schemePrice;
  final String price;
  final String purchasePrice;

  LineItem({
    required this.itemCode,
    required this.productName,
    required this.qty,
    required this.schemePoints,
    required this.batchId,
    required this.schemePrice,
    required this.price,
    required this.purchasePrice,
  });

  Map<String, dynamic> toJson() => {
    'itemCode': itemCode,
    'product_name': productName,
    'qty': qty,
    'scheme_points': schemePoints,
    'batch_id': batchId,
    'scheme_price': schemePrice,
    'price': price,
    'purchase_price': purchasePrice,
  };
}
