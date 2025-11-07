class ProductCatalogueResponse {
  final int statusCode;
  final String message;
  final List<ProductData> data;

  ProductCatalogueResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ProductCatalogueResponse.fromJson(Map<String, dynamic> json) {
    return ProductCatalogueResponse(
      statusCode: json['status_code'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ProductData.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status_code': statusCode,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductData {
  final String name;
  final String mrp;
  final String mainImage;
  final String? productUrl;

  ProductData({
    required this.name,
    required this.mrp,
    required this.mainImage,
    this.productUrl,

  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      name: json['name'] ?? '',
      mrp: json['mrp'] ?? '',
      mainImage: json['main_image'] ?? '',
      productUrl: json['product_info_web_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mrp': mrp,
      'main_image': mainImage,
      'product_info_web_url':productUrl,
    };
  }
}
