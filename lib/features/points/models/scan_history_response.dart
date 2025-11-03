class ScanHistoryResponse {
  final int success;
  final List<ScanHistoryItem> data;

  ScanHistoryResponse({
    required this.success,
    required this.data,
  });

  factory ScanHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ScanHistoryResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ScanHistoryItem.fromJson(e))
          .toList(),
    );
  }
}

class ScanHistoryItem {
  final String? id;
  final String? uniqueCode;
  final String? level;
  final String? points;
  final String? totalAdjusted;
  final String? schemeName;
  final String? createdAt;
  final Product? product;

  ScanHistoryItem({
    this.id,
    this.uniqueCode,
    this.level,
    this.points,
    this.totalAdjusted,
    this.schemeName,
    this.createdAt,
    this.product,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'],
      uniqueCode: json['unique_code'],
      level: json['level'],
      points: json['points']?.toString(),
      totalAdjusted: json['total_adjusted']?.toString(),
      schemeName: json['scheme_name'],
      createdAt: json['createdAt'],
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}

class Product {
  final String? id;
  final String? name;
  final String? mainImage;

  Product({this.id, this.name, this.mainImage});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      mainImage: json['main_image'],
    );
  }
}
