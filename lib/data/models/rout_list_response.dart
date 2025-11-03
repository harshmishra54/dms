class RoutListResponse {
  final int success;
  final String message;
  final List<TsiRoute> data;

  RoutListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RoutListResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];

    List<TsiRoute> parsedData = [];

    if (dataJson != null && dataJson is List) {
      parsedData = dataJson
          .map((item) => TsiRoute.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return RoutListResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: parsedData,
    );
  }
}

class TsiRoute {
  final String id;
  final String tsiId;
  final String tsiName;
  final String routeId;
  final String routeName;
  final String status;
  final int totalRetailers;
  final int totalDistributors;
  final bool isExpired;
  final bool isDiscarded;
  final bool isUnfollow;
  final String uId;
  final String createdAt;
  final String updatedAt;
  final String? date;

  TsiRoute({
    required this.id,
    required this.tsiId,
    required this.tsiName,
    required this.routeId,
    required this.routeName,
    required this.status,
    required this.totalRetailers,
    required this.totalDistributors,
    required this.isExpired,
    required this.isDiscarded,
    required this.isUnfollow,
    required this.uId,
    required this.createdAt,
    required this.updatedAt,
    this.date,
  });

  factory TsiRoute.fromJson(Map<String, dynamic> json) {
    return TsiRoute(
      id: json['id'] ?? '',
      tsiId: json['tsi_id'] ?? '',
      tsiName: json['tsi_name'] ?? '',
      routeId: json['route_id'] ?? '',
      routeName: json['route_name'] ?? '',
      status: json['status'] ?? '',
      totalRetailers: json['total_retailers'] ?? 0,
      totalDistributors: json['total_distributors'] ?? 0,
      isExpired: (json['is_expired'] ?? false) == true,
      isDiscarded: (json['is_discarded'] ?? false) == true,
      isUnfollow: (json['is_unfollow'] ?? false) == true,
      uId: json['u_id'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      date: json['date'] ?? '',

    );
  }
}
