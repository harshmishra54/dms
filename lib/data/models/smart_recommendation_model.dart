/// Root-level response model for Smart AI recommendations or chat replies.
class RecommendationResponse {
  RecommendationResponse({
    this.query,
    this.message,
    this.interpretation,
    required this.recommendations,
  });

  /// Original user query (e.g., "wheat rust")
  final String? query;

  /// Optional chat or fallback message
  final String? message;

  /// Parsed interpretation of the user's intent (crop, problem, etc.)
  final Interpretation? interpretation;

  /// List of recommendations (can be empty in chat/fallback)
  final List<Recommendation> recommendations;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    final recs = (json['recommendations'] as List?)
        ?.map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
        .toList() ??
        <Recommendation>[];

    return RecommendationResponse(
      query: json['query'] as String?,
      message: json['message'] as String?,
      interpretation: json['interpretation'] != null
          ? Interpretation.fromJson(
          json['interpretation'] as Map<String, dynamic>)
          : null,
      recommendations: recs,
    );
  }

  Map<String, dynamic> toJson() => {
    if (query != null) 'query': query,
    if (message != null) 'message': message,
    if (interpretation != null) 'interpretation': interpretation!.toJson(),
    'recommendations': recommendations.map((r) => r.toJson()).toList(),
  };

  bool get isChatResponse => recommendations.isEmpty && message != null;

  @override
  String toString() =>
      'RecommendationResponse(query: $query, message: $message, interpretation: $interpretation, recommendations: ${recommendations.length})';
}

/// Represents AI interpretation like { crop: "Wheat", problem: "Rust", advice: "..." }
class Interpretation {
  Interpretation({
    required this.crop,
    required this.problem,
    this.advice,
  });

  final String crop;
  final String problem;
  final String? advice;

  factory Interpretation.fromJson(Map<String, dynamic> json) => Interpretation(
    crop: (json['crop'] ?? 'Unknown').toString(),
    problem: (json['problem'] ?? 'Unknown').toString(),
    advice: json['advice']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'problem': problem,
    if (advice != null) 'advice': advice,
  };

  @override
  String toString() => 'Interpretation(crop: $crop, problem: $problem, advice: $advice)';
}

/// Represents each recommendation item from API
class Recommendation {
  Recommendation({
    required this.name,
    required this.crop,
    required this.disease,
    this.dosage,
    this.waterVolume,
    this.season,
    this.area,
    this.alreadyUsing = false,
    this.directionsOfUse,
    this.productUrl,
    this.image,
    List<String>? features,
    this.advice,
    this.reason,
    this.score,
  }) : features = features ?? <String>[];

  final String name;
  final String crop;
  final String disease;
  final String? dosage;
  final String? waterVolume;
  final String? season;
  final String? area;
  final bool alreadyUsing;
  final String? directionsOfUse;
  final String? productUrl;
  final String? image;
  final List<String> features;
  final String? advice;
  final String? reason;
  final int? score;

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final List<String> featureList = (rawFeatures is List)
        ? rawFeatures.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return Recommendation(
      name: (json['name'] ?? '').toString(),
      crop: (json['crop'] ?? '').toString(),
      disease: (json['disease'] ?? '').toString(),
      dosage: json['dosage']?.toString(),
      waterVolume:
      json['waterVolume']?.toString() ?? json['water_volume']?.toString(),
      season: json['season']?.toString(),
      area: json['area']?.toString(),
      alreadyUsing: json['alreadyUsing'] == true ||
          json['already_using'] == true,
      directionsOfUse: json['directionsOfUse']?.toString() ??
          json['directions_of_use']?.toString(),
      productUrl:
      json['product_url']?.toString() ?? json['productUrl']?.toString(),
      image: json['image']?.toString(),
      features: featureList,
      advice: json['advice']?.toString(),
      reason: json['reason']?.toString(),
      score: (json['score'] is num)
          ? (json['score'] as num).toInt()
          : int.tryParse(json['score']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'crop': crop,
    'disease': disease,
    if (dosage != null) 'dosage': dosage,
    if (waterVolume != null) 'waterVolume': waterVolume,
    if (season != null) 'season': season,
    if (area != null) 'area': area,
    'alreadyUsing': alreadyUsing,
    if (directionsOfUse != null) 'directionsOfUse': directionsOfUse,
    if (productUrl != null) 'product_url': productUrl,
    if (image != null) 'image': image,
    if (features.isNotEmpty) 'features': features,
    if (advice != null) 'advice': advice,
    if (reason != null) 'reason': reason,
    if (score != null) 'score': score,
  };

  @override
  String toString() =>
      'Recommendation(name: $name, crop: $crop, disease: $disease, advice: $advice, score: $score)';
}
/// Request model for sending recommendation query
/// Request model for sending recommendation query
class RecommendationRequest {
  RecommendationRequest({
    required this.query,
    this.farmer, // <-- make nullable
    this.currentProducts = const [],
  });

  final String query;
  final Farmer? farmer; // <-- nullable now
  final List<String> currentProducts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'query': query};
    if (farmer != null) {
      map['farmer'] = farmer!.toJson();
    }
    if (currentProducts.isNotEmpty) {
      map['currentProducts'] = currentProducts;
    }
    return map;
  }
}


/// Farmer details for recommendation context
class Farmer {
  Farmer({
    required this.name,
    this.crop,
    this.problem,
    this.area,
    this.season,
  });

  final String name;
  final String? crop;
  final String? problem;
  final double? area;
  final String? season;

  factory Farmer.fromJson(Map<String, dynamic> json) => Farmer(
    name: (json['name'] ?? '').toString(),
    crop: json['crop']?.toString(),
    problem: json['problem']?.toString(),
    area: (json['area'] is num)
        ? (json['area'] as num).toDouble()
        : double.tryParse(json['area']?.toString() ?? ''),
    season: json['season']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (crop != null) 'crop': crop,
    if (problem != null) 'problem': problem,
    if (area != null) 'area': area,
    if (season != null) 'season': season,
  };
}
