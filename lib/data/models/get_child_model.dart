class GetChildsRequest {
  final String id;

  GetChildsRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
class GetChildsResponse {
  final int success;
  final String message;
  final int count;
  final List<ChildUser> data;

  GetChildsResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
  });

  factory GetChildsResponse.fromJson(Map<String, dynamic> json) {
    return GetChildsResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ChildUser.fromJson(e))
          .toList(),
    );
  }
}
class ChildUser {
  final String id;
  final String name;
  final String email;

  ChildUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ChildUser.fromJson(Map<String, dynamic> json) {
    return ChildUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
