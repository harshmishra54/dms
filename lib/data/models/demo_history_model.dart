class DemoHistoryRequest {
  final String userId;

  DemoHistoryRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
    };
  }
}
class DemoHistoryResponse {
  final int? success;
  final String? message;
  final int? count;
  final List<DemoHistoryItem> data;

  DemoHistoryResponse({
    this.success,
    this.message,
    this.count,
    required this.data,
  });

  factory DemoHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DemoHistoryResponse(
      success: json['success'],
      message: json['message'],
      count: json['count'],
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => DemoHistoryItem.fromJson(e))
          .toList(),
    );
  }
}
class DemoHistoryItem {
  final String? id;
  final bool? isActive;
  final DemoHistoryData? data;
  final String? creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DemoHistoryItem({
    this.id,
    this.isActive,
    this.data,
    this.creatorId,
    this.createdAt,
    this.updatedAt,
  });

  factory DemoHistoryItem.fromJson(Map<String, dynamic> json) {
    return DemoHistoryItem(
      id: json['id'],
      isActive: json['is_active'],
      data: json['data'] != null
          ? DemoHistoryData.fromJson(json['data'])
          : null,
      creatorId: json['creator_id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}
class DemoHistoryData {
  final String? message;

  DemoHistoryData({this.message});

  factory DemoHistoryData.fromJson(Map<String, dynamic> json) {
    return DemoHistoryData(
      message: json['message'],
    );
  }
}
