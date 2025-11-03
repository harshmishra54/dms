class UpdateBeatPlanDoctorIndividualRequest {
  final String id;
  final String status;
  final String fid;

  UpdateBeatPlanDoctorIndividualRequest({
    required this.id,
    required this.status,
    required this.fid,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'fid': fid,
    };
  }
}

class UpdateBeatPlanDoctorIndividualResponse {
  final int? success;
  final String? message;
  final BeatPlanDoctorData? data;

  UpdateBeatPlanDoctorIndividualResponse({
    this.success,
    this.message,
    this.data,
  });

  factory UpdateBeatPlanDoctorIndividualResponse.fromJson(
      Map<String, dynamic> json) {
    return UpdateBeatPlanDoctorIndividualResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? BeatPlanDoctorData.fromJson(json['data'])
          : null,
    );
  }
}

class BeatPlanDoctorData {
  final String? id;
  final List<FarmerStatus>? farmers;
  final String? date;
  final String? userId;
  final String? status;
  final String? routeName;
  final String? createdAt;
  final String? updatedAt;

  BeatPlanDoctorData({
    this.id,
    this.farmers,
    this.date,
    this.userId,
    this.status,
    this.routeName,
    this.createdAt,
    this.updatedAt,
  });

  factory BeatPlanDoctorData.fromJson(Map<String, dynamic> json) {
    return BeatPlanDoctorData(
      id: json['id'],
      farmers: json['farmers'] != null
          ? List<FarmerStatus>.from(
          json['farmers'].map((x) => FarmerStatus.fromJson(x)))
          : [],
      date: json['date'],
      userId: json['user_id'],
      status: json['status'],
      routeName: json['route_name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class FarmerStatus {
  final String? id;
  final String? status;

  FarmerStatus({
    this.id,
    this.status,
  });

  factory FarmerStatus.fromJson(Map<String, dynamic> json) {
    return FarmerStatus(
      id: json['id'],
      status: json['status'],
    );
  }
}
