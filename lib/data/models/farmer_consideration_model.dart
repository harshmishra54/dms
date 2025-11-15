// farmer_consideration_model.dart

// -------------------------
// Request Model
// -------------------------
class FarmerConsiderationRequest {
  final String createdBy;

  FarmerConsiderationRequest({required this.createdBy});

  Map<String, dynamic> toJson() {
    return {
      'created_by': createdBy,
    };
  }
}

// -------------------------
// Response Model
// -------------------------
class FarmerConsiderationResponse {
  final int success;
  final int count;
  final List<Farmer> farmers;
  final String message;

  FarmerConsiderationResponse({
    required this.success,
    required this.count,
    required this.farmers,
    required this.message,
  });

  factory FarmerConsiderationResponse.fromJson(Map<String, dynamic> json) {
    return FarmerConsiderationResponse(
      success: json['success'] ?? 0,
      count: json['count'] ?? 0,
      farmers: (json['farmers'] as List<dynamic>?)
          ?.map((e) => Farmer.fromJson(e))
          .toList() ??
          [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'count': count,
      'farmers': farmers.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class Farmer {
  final String id;
  final String name;

  Farmer({
    required this.id,
    required this.name,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
