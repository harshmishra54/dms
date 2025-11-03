import 'distributor_data.dart';

class DistributorResponse {
  final int success;
  final String message;
  final List<DistributorData> data;

  DistributorResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DistributorResponse.fromJson(Map<String, dynamic> json) {
    return DistributorResponse(
      success: json["success"] ?? 0,
      message: json["message"] ?? '',
      data: (json["data"] as List<dynamic>?)
          ?.map((item) => DistributorData.fromJson(item))
          .toList()
          ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data.map((d) => d.toJson()).toList(),
    };
  }
}
