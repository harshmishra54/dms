import 'dart:convert';


class CompleteDemoRequest {
  final String demoId;

  CompleteDemoRequest({required this.demoId});

  Map<String, dynamic> toJson() {
    return {
      'demo_id': demoId,
    };
  }

  String toJsonString() => json.encode(toJson());
}

class CompleteDemoResponse {
  final int success;
  final String message;
  final CompleteDemoData data;

  CompleteDemoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CompleteDemoResponse.fromJson(Map<String, dynamic> json) {
    return CompleteDemoResponse(
      success: json['success'] as int,
      message: json['message'] as String,
      data: CompleteDemoData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class CompleteDemoData {
  final String id;
  final bool isActive;
  final DemoDetails data;
  final String creatorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompleteDemoData({
    required this.id,
    required this.isActive,
    required this.data,
    required this.creatorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompleteDemoData.fromJson(Map<String, dynamic> json) {
    return CompleteDemoData(
      id: json['id'] as String,
      isActive: json['is_active'] as bool,
      data: DemoDetails.fromJson(json['data']),
      creatorId: json['creator_id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_active': isActive,
      'data': data.toJson(),
      'creator_id': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class DemoDetails {
  final String message;

  DemoDetails({required this.message});

  factory DemoDetails.fromJson(Map<String, dynamic> json) {
    return DemoDetails(
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}

// Optional helper function
CompleteDemoResponse completeDemoResponseFromJson(String str) =>
    CompleteDemoResponse.fromJson(json.decode(str));

String completeDemoResponseToJson(CompleteDemoResponse data) =>
    json.encode(data.toJson());
