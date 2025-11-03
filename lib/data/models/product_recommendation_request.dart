class CropItem {
  final String name; // crop name
  final String? disease; // optional
  final List<String>? currentProducts; // optional

  CropItem({
    required this.name,
    this.disease,
    this.currentProducts,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'disease': disease ?? 'NA',
      'currentProducts': currentProducts ?? [],
    };
  }
}

class Farmer {
  final double area; // in acres
  final String season;

  Farmer({required this.area, required this.season});

  Map<String, dynamic> toJson() {
    return {
      'area': area,
      'season': season,
    };
  }
}

class ProductRecommendationRequest {
  final List<CropItem> crops;
  final Farmer farmer;

  ProductRecommendationRequest({required this.crops, required this.farmer});

  Map<String, dynamic> toJson() {
    return {
      'crops': crops.map((c) => c.toJson()).toList(),
      'farmer': farmer.toJson(),
    };
  }
}

class ProductRecommendationResponse {
  final String query;
  final List<Recomm> recommendations; // changed here

  ProductRecommendationResponse({required this.query, required this.recommendations});

  factory ProductRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return ProductRecommendationResponse(
      query: json['query'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => Recomm.fromJson(e))
          .toList(),
    );
  }
}

class Recomm { // renamed from Recommendation
  final String name;
  final String crop;
  final String disease;
  final String? dosage;
  final String? waterVolume;
  final String season;
  final String area;
  final bool alreadyUsing;
  final String directionsOfUse;
  final String productUrl;
  final String image;
  final List<String> features;
  final String reason;
  final int score;

  Recomm({
    required this.name,
    required this.crop,
    required this.disease,
    this.dosage,
    this.waterVolume,
    required this.season,
    required this.area,
    required this.alreadyUsing,
    required this.directionsOfUse,
    required this.productUrl,
    required this.image,
    required this.features,
    required this.reason,
    required this.score,
  });

  factory Recomm.fromJson(Map<String, dynamic> json) {
    return Recomm(
      name: json['name'] ?? '',
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? '',
      dosage: json['dosage'],
      waterVolume: json['waterVolume'],
      season: json['season'] ?? '',
      area: json['area'] ?? '',
      alreadyUsing: json['alreadyUsing'] ?? false,
      directionsOfUse: json['directionsOfUse'] ?? '',
      productUrl: json['product_url'] ?? '',
      image: json['image'] ?? '',
      features: (json['features'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      reason: json['reason'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}
