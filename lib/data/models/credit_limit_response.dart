class CreditListRequest {
  final String roleId;
  final String requestId;

  CreditListRequest({required this.roleId, required this.requestId});

  Map<String, dynamic> toJson() => {
    "role_id": roleId,
    "request_id": requestId,
  };
}

class CreditLimitResponse {
  final int success;
  final String message;
  final List<CreditListDataResponse> data;

  CreditLimitResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreditLimitResponse.fromJson(Map<String, dynamic> json) {
    return CreditLimitResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CreditListDataResponse.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class CreditListDataResponse {

  final String? currentLimit;
  final String? approvedLimit;
  final String? requestedLimit;
  final String? status;


  CreditListDataResponse({

    this.currentLimit,
    this.approvedLimit,
    this.requestedLimit,
    this.status,

  });

  factory CreditListDataResponse.fromJson(Map<String, dynamic> json) {
    return CreditListDataResponse(

      currentLimit: json['current_limit']?.toString(),
      approvedLimit: json['approved_limit']?.toString(),
      requestedLimit: json['requested_limit']?.toString(),
      status: json['status'],

    );
  }
}
