class Recommendation {
  final String name;         // Product name or crop name for advice
  final String crop;         // Crop name
  final String disease;      // Disease/problem or condition
  final String dosage;       // Dosage if product exists
  final String waterVolume;  // Water volume if product exists
  final String advice;       // Advice or preventive measures
  final String? productUrl;  // Product link if exists
  final String? image;       // Product image if exists
  final List<dynamic>? features; // Product features if exists

  Recommendation({
    required this.name,
    required this.crop,
    required this.disease,
    required this.dosage,
    required this.waterVolume,
    required this.advice,
    this.productUrl,
    this.image,
    this.features,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      name: json['name'] ?? json['crop'] ?? '',
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? json['condition'] ?? '',
      dosage: json['dosage'] ?? '',
      waterVolume: json['waterVolume'] ?? '',
      advice: json['advice'] ?? '',
      productUrl: json['product_url'],
      image: json['image'],
      features: json['features'],
    );
  }

  bool get isProductRecommendation {
    // Returns true if this is a full product recommendation
    return name.isNotEmpty &&
        dosage.isNotEmpty &&
        waterVolume.isNotEmpty &&
        productUrl != null;
  }
}
