class TodayRouteScheduleResponse {
  final int success;
  final String message;
  final TodayRouteData? data;

  TodayRouteScheduleResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory TodayRouteScheduleResponse.fromJson(Map<String, dynamic> json) {
    return TodayRouteScheduleResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? TodayRouteData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class TodayRouteData {
  final int pending;
  final int complete;
  final int total;
  final List<CompletedUser> completedUsers;

  TodayRouteData({
    required this.pending,
    required this.complete,
    required this.total,
    required this.completedUsers,
  });

  factory TodayRouteData.fromJson(Map<String, dynamic> json) {
    return TodayRouteData(
      pending: json['pending'] ?? 0,
      complete: json['complete'] ?? 0,
      total: json['total'] ?? 0,
      completedUsers: (json['completed_users'] as List<dynamic>?)
          ?.map((e) => CompletedUser.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "pending": pending,
      "complete": complete,
      "total": total,
      "completed_users": completedUsers.map((e) => e.toJson()).toList(),
    };
  }
}

class CompletedUser {
  final String mobileNo;
  final String name;
  final String type;
  final double latitude;
  final double longitude;

  CompletedUser({
    required this.mobileNo,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  factory CompletedUser.fromJson(Map<String, dynamic> json) {
    return CompletedUser(
      mobileNo: json['mobile_no']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "mobile_no": mobileNo,
      "name": name,
      "type": type,
      "latitude": latitude,
      "longitude": longitude,
    };
  }
}
