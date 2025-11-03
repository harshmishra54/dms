class RoutVisitUserListResponse {
  final int success;
  final String message;
  final LocationData? data;

  RoutVisitUserListResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RoutVisitUserListResponse.fromJson(Map<String, dynamic> json) {
    return RoutVisitUserListResponse(
      success: json['success'] is int
          ? json['success']
          : int.tryParse(json['success'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? LocationData.fromJson(json['data'])
          : null,
    );
  }
}

class LocationData {
  final List<LocationItem> retailers;
  final List<LocationItem> distributors;
  final String status; // ✅ global route status

  LocationData({
    required this.retailers,
    required this.distributors,
    required this.status,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    List<LocationItem> parseItems(dynamic list) {
      if (list is List) {
        return list
            .map((e) => e is Map<String, dynamic> ? LocationItem.fromJson(e) : null)
            .whereType<LocationItem>()
            .toList();
      }
      return [];
    }

    return LocationData(
      retailers: parseItems(json['retailers']),
      distributors: parseItems(json['distributors']),
      status: json['status']?.toString() ?? '', // ✅ fetch global status here
    );
  }
}

class LocationItem {
  final String locationId;
  final String name;
  final String mobileNo;
  final String? status; // individual retailer/distributor status
  final String firmName;
  final int roleId;

  LocationItem({
    required this.locationId,
    required this.name,
    required this.mobileNo,
    required this.status,
    required this.firmName,
    required this.roleId,
  });

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    return LocationItem(
      locationId: json['location']?.toString() ?? json['location_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      status: json['status']?.toString(),
      firmName: json['firm_name']?.toString() ?? '',
      roleId: int.tryParse(json['role_id'].toString()) ?? 0,
    );
  }
}
