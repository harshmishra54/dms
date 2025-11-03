// credit_limit_history_model.dart

/// Request Model
class CreditLimitHistoryRequest {
  final String userId;

  CreditLimitHistoryRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}

/// Response Model
class CreditLimitHistoryResponse {
  final int success;
  final String message;
  final List<CreditLimitHistory> data;

  CreditLimitHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreditLimitHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<CreditLimitHistory> parsedData = [];

    if (rawData != null && rawData is List) {
      parsedData.addAll(
        rawData.map((item) {
          if (item is Map<String, dynamic>) {
            return CreditLimitHistory.fromJson(item);
          } else {
            return CreditLimitHistory.empty();
          }
        }),
      );
    }

    return CreditLimitHistoryResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class CreditLimitHistory {
  final String id;
  final String userId;
  final String previousLimit;
  final String newLimit;
  final String changeAmount;
  final String changeType;
  final String description;
  final DateTime createdAt;

  CreditLimitHistory({
    required this.id,
    required this.userId,
    required this.previousLimit,
    required this.newLimit,
    required this.changeAmount,
    required this.changeType,
    required this.description,
    required this.createdAt,
  });

  /// Fallback empty object in case of invalid/missing data
  factory CreditLimitHistory.empty() {
    return CreditLimitHistory(
      id: '',
      userId: '',
      previousLimit: '0',
      newLimit: '0',
      changeAmount: '0',
      changeType: '',
      description: '',
      createdAt: DateTime.now(),
    );
  }

  factory CreditLimitHistory.fromJson(Map<String, dynamic> json) {
    return CreditLimitHistory(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      previousLimit: json['previous_limit'] ?? '0',
      newLimit: json['new_limit'] ?? '0',
      changeAmount: json['change_amount'] ?? '0',
      changeType: json['change_type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'previous_limit': previousLimit,
      'new_limit': newLimit,
      'change_amount': changeAmount,
      'change_type': changeType,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
