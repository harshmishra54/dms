class SchemeResponse {
  final String success; // keep as String for flexibility
  final String message;
  final List<SchemeItem> data;

  SchemeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SchemeResponse.fromJson(Map<String, dynamic> json) {
    return SchemeResponse(
      success: json['success'].toString(),
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SchemeItem.fromJson(e))
          .toList(),
    );
  }
}

class SchemeItem {
  final String schemeId;
  final String schemeName;
  final List<Brand> products;
  final String schemeImage;
  bool isExpanded; // for UI expand/collapse

  SchemeItem({
    required this.schemeId,
    required this.schemeName,
    required this.products,
    required this.schemeImage,
    this.isExpanded = false,
  });

  factory SchemeItem.fromJson(Map<String, dynamic> json) {
    return SchemeItem(
      schemeId: json['scheme_id']?.toString() ?? '',
      schemeName: json['scheme_name']?.toString() ?? '',
      schemeImage: json['scheme_image']?.toString() ?? '',
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Brand.fromJson(e))
          .toList(),
    );
  }
}

class Brand {
  final String productId;
  final String displayName;
  final List<Level> levels;

  Brand({
    required this.productId,
    required this.displayName,
    required this.levels,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      productId: json['product_id']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      levels: (json['levels'] as List<dynamic>? ?? [])
          .map((e) => Level.fromJson(e))
          .toList(),
    );
  }
}

class Level {
  final String level;
  final int totalPoints; // store as int

  Level({
    required this.level,
    required this.totalPoints,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      level: json['level']?.toString() ?? '',
      totalPoints: (json['points'] is int)
          ? json['points']
          : int.tryParse(json['points'].toString()) ?? 0,
    );
  }
}

