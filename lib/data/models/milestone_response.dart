// lib/data/models/milestone_response.dart

class MilestoneRequest {
  final int roleId;

  MilestoneRequest({
    required this.roleId,
  });

  /// Convert request model to JSON for API body
  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
    };
  }
}

class MilestoneResponse {
  final int success;
  final String message;
  final List<MilestoneData> data;

  MilestoneResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MilestoneResponse.fromJson(Map<String, dynamic> json) {
    return MilestoneResponse(
      success: json['success'] ?? 0, // fixed typo: 'sucess' → 'success'
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MilestoneData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class MilestoneData {
  final int value;
  final String label;
  final String image;

  MilestoneData({
    required this.value,
    required this.label,
    required this.image,
  });

  factory MilestoneData.fromJson(Map<String, dynamic> json) {
    return MilestoneData(
      value: json['value'] ?? 0,
      label: json['label'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
