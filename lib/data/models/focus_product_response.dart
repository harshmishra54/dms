class FocusProductResponse {
  final int success;
  final List<FocusProduct> data;

  FocusProductResponse({
    required this.success,
    required this.data,
  });

  factory FocusProductResponse.fromJson(Map<String, dynamic> json) {
    return FocusProductResponse(
      success: json['success'] ?? 0,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FocusProduct.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class FocusProduct {
  final String id;
  final String sku;
  final bool focus;
  final bool seasonal;

  FocusProduct({
    required this.id,
    required this.sku,
    required this.focus,
    required this.seasonal,
  });

  factory FocusProduct.fromJson(Map<String, dynamic> json) {
    return FocusProduct(
      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      focus: json['focus'] ?? false,
      seasonal: json['seasonal'] ?? false,
    );
  }
}
