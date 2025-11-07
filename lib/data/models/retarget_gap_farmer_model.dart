// lib/models/retarget_gap_farmer_model.dart
import 'package:flutter/foundation.dart';

class RetargetGapFarmerRequest {
  final String id;
  final String duration; // e.g., "6 months" or "1 year"

  RetargetGapFarmerRequest({
    required this.id,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "duration": duration,
    };
  }
}

class RetargetGapFarmerResponse {
  final int success;
  final String message;
  final List<Farmer> data;

  RetargetGapFarmerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RetargetGapFarmerResponse.fromJson(Map<String, dynamic> json) {
    var farmers = <Farmer>[];
    if (json['data'] != null) {
      farmers = List<Farmer>.from(
          json['data'].map((farmer) => Farmer.fromJson(farmer)));
    }

    return RetargetGapFarmerResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: farmers,
    );
  }
}

class Farmer {
  final String farmerId;
  final String farmerName;

  Farmer({
    required this.farmerId,
    required this.farmerName,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      farmerId: json['farmer_id'] ?? '',
      farmerName: json['farmer_name'] ?? '',
    );
  }
}
