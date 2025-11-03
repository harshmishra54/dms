class ToLocationResponse {
  final int success;
  final String response;
  final String message;
  final List<DistributorData> data;

  ToLocationResponse({
    required this.success,
    required this.response,
    required this.message,
    required this.data,
  });

  factory ToLocationResponse.fromJson(Map<String, dynamic> json) {
    return ToLocationResponse(
      success: json['success'] ?? 0,
      response: json['response'] ?? '',
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DistributorData.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class DistributorData {
  final String id;
  final String name;

  DistributorData({
    required this.id,
    required this.name,
  });

  factory DistributorData.fromJson(Map<String, dynamic> json) {
    return DistributorData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  String toString() {
    return name; // For DropdownSearch to display name
  }
}
