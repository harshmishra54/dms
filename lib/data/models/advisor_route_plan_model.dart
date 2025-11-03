import 'dart:convert';

/// Request Model
class AddBeatPlanDoctorRequest {
  final String userId;
  final List<String> farmerIds;
  final String date;
  final String routName;

  AddBeatPlanDoctorRequest({
    required this.userId,
    required this.farmerIds,
    required this.date,
    required this.routName
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'farmer_ids': farmerIds,
      'date': date,
      'route_name': routName,
    };
  }

  String toRawJson() => json.encode(toJson());
}

/// Response Model
class AddBeatPlanDoctorResponse {
  final int success;
  final String message;
  final BeatPlanDoctorData? data;

  AddBeatPlanDoctorResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AddBeatPlanDoctorResponse.fromJson(Map<String, dynamic> json) {
    return AddBeatPlanDoctorResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? BeatPlanDoctorData.fromJson(json['data'])
          : null,
    );
  }

  factory AddBeatPlanDoctorResponse.fromRawJson(String str) =>
      AddBeatPlanDoctorResponse.fromJson(json.decode(str));
}

class BeatPlanDoctorData {
  final String id;
  final String userId;
  final List<String> farmerIds;
  final String date;
  final String updatedAt;
  final String createdAt;

  BeatPlanDoctorData({
    required this.id,
    required this.userId,
    required this.farmerIds,
    required this.date,
    required this.updatedAt,
    required this.createdAt,
  });

  factory BeatPlanDoctorData.fromJson(Map<String, dynamic> json) {
    return BeatPlanDoctorData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      farmerIds: List<String>.from(json['farmer_ids'] ?? []),
      date: json['date'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
