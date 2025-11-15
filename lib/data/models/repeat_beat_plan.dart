// repeat_plan_model.dart

// ----------------------
// REQUEST MODEL
// ----------------------
class RepeatPlanRequest {
  final String planId;
  final String newDate;

  RepeatPlanRequest({
    required this.planId,
    required this.newDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'new_date': newDate,
    };
  }
}

// ----------------------
// RESPONSE MODEL
// ----------------------
class RepeatPlanResponse {
  final int success;
  final String message;
  final RepeatPlanData? data;

  RepeatPlanResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RepeatPlanResponse.fromJson(Map<String, dynamic> json) {
    return RepeatPlanResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data:
      json['data'] != null ? RepeatPlanData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class RepeatPlanData {
  final String? status;
  final String? id;
  final String? routeName;
  final String? userId;
  final List<Farmer>? farmers;
  final String? date;
  final String? updatedAt;
  final String? createdAt;
  final String? reason;

  RepeatPlanData({
    this.status,
    this.id,
    this.routeName,
    this.userId,
    this.farmers,
    this.date,
    this.updatedAt,
    this.createdAt,
    this.reason,
  });

  factory RepeatPlanData.fromJson(Map<String, dynamic> json) {
    return RepeatPlanData(
      status: json['status'],
      id: json['id'],
      routeName: json['route_name'],
      userId: json['user_id'],
      farmers: json['farmers'] != null
          ? List<Farmer>.from(
        json['farmers'].map((x) => Farmer.fromJson(x)),
      )
          : [],
      date: json['date'],
      updatedAt: json['updatedAt'],
      createdAt: json['createdAt'],
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'id': id,
      'route_name': routeName,
      'user_id': userId,
      'farmers': farmers?.map((x) => x.toJson()).toList(),
      'date': date,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'reason': reason,
    };
  }
}

class Farmer {
  final String? id;
  final String? status;

  Farmer({
    this.id,
    this.status,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
