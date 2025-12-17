class RouteActivityRequest {
  final String id;

  RouteActivityRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
class RouteActivityResponse {
  final int success;
  final String message;
  final int pending;
  final int complete;
  final int total;
  final List<CompletedUser> completedUsers;

  RouteActivityResponse({
    required this.success,
    required this.message,
    required this.pending,
    required this.complete,
    required this.total,
    required this.completedUsers,
  });

  factory RouteActivityResponse.fromJson(Map<String, dynamic> json) {
    final routeSummary = json['data']?['route_summary'] ?? {};

    return RouteActivityResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      pending: routeSummary['pending'] ?? 0,
      complete: routeSummary['complete'] ?? 0,
      total: routeSummary['total'] ?? 0,
      completedUsers: (routeSummary['completed_users'] as List? ?? [])
          .map((e) => CompletedUser.fromJson(e))
          .toList(),
    );
  }
}


class CompletedUser {
  final String? id;
  final int? roleId;
  final String? name;
  final String? countryCode;
  final String? phone;
  final String? mobileNo;
  final String? type;
  final String? latitude;
  final String? longitude;

  CompletedUser({
    this.id,
    this.roleId,
    this.name,
    this.countryCode,
    this.phone,
    this.mobileNo,
    this.type,
    this.latitude,
    this.longitude,
  });

  factory CompletedUser.fromJson(Map<String, dynamic> json) {
    return CompletedUser(
      id: json['id'],
      roleId: json['role_id'],
      name: json['name'],
      countryCode: json['country_code'],
      phone: json['phone'],
      mobileNo: json['mobile_no'],
      type: json['type'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }
}

