class DistributorUnderTsiRequestModel {
  final String id;

  DistributorUnderTsiRequestModel({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory DistributorUnderTsiRequestModel.fromJson(Map<String, dynamic> json) {
    return DistributorUnderTsiRequestModel(
      id: json['id'] ?? '',
    );
  }
}
class RetailerUnderTSIModelRequest {
  final String id;

  RetailerUnderTSIModelRequest({required this.id});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory RetailerUnderTSIModelRequest.fromJson(Map<String, dynamic> json) {
    return RetailerUnderTSIModelRequest(
      id: json['id'] ?? '',
    );
  }
}