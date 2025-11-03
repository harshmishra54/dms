// product_price_model.dart
class ProductPrice {
  final String itemCode;
  final String productName;
  final String uniqueName;
  final double price;
  final double schemePrice;

  ProductPrice({
    required this.itemCode,
    required this.productName,
    required this.uniqueName,
    required this.price,
    required this.schemePrice,
  });

  Map<String, dynamic> toJson() {
    return {
      "itemCode": itemCode,
      "productName": productName,
      "uniqueName": uniqueName,
      "price": price,
      "schemePrice": schemePrice,
    };
  }

  factory ProductPrice.fromExcelRow(Map<String, dynamic> row) {
    return ProductPrice(
      itemCode: row['itemCode']?.toString() ?? '',
      productName: row['productName']?.toString() ?? '',
      uniqueName: row['uniqueName']?.toString() ?? '',
      price: double.tryParse(row['price'].toString()) ?? 0.0,
      schemePrice: double.tryParse(row['schemePrice'].toString()) ?? 0.0,
    );
  }
}

// update_response_model.dart
class UpdateData {
  final int totalProducts;
  final int updated;
  final int skipped;

  UpdateData({
    required this.totalProducts,
    required this.updated,
    required this.skipped,
  });

  factory UpdateData.fromJson(Map<String, dynamic> json) {
    return UpdateData(
      totalProducts: json['total_products'] is int
          ? json['total_products']
          : int.tryParse(json['total_products']?.toString() ?? '0') ?? 0,
      updated: json['updated'] is int
          ? json['updated']
          : int.tryParse(json['updated']?.toString() ?? '0') ?? 0,
      skipped: json['skipped'] is int
          ? json['skipped']
          : int.tryParse(json['skipped']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_products': totalProducts,
      'updated': updated,
      'skipped': skipped,
    };
  }
}

class UpdateResponse {
  final int success; // API returns 1/0 in your example
  final String message;
  final UpdateData? data;

  UpdateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateResponse.fromJson(Map<String, dynamic> json) {
    return UpdateResponse(
      success: json['success'] is int
          ? json['success']
          : int.tryParse(json['success']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? UpdateData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
