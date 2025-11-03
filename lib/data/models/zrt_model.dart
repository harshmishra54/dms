import 'dart:convert';

/// ------------ REQUEST MODEL ------------
class ZrtRequest {
  final String id;

  ZrtRequest({required this.id});

  factory ZrtRequest.fromJson(Map<String, dynamic> json) {
    return ZrtRequest(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  static ZrtRequest fromJsonString(String str) =>
      ZrtRequest.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

/// ------------ RESPONSE MODEL ------------
class ZrtResponse {
  final int success;
  final String message;
  final ZrtData? data;

  ZrtResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ZrtResponse.fromJson(Map<String, dynamic> json) {
    return ZrtResponse(
      success: json['success'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? ZrtData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }

  static ZrtResponse fromJsonString(String str) =>
      ZrtResponse.fromJson(json.decode(str));

  String toJsonString() => json.encode(toJson());
}

class ZrtData {
  final String zoneId;
  final String regionId;
  final String territoryId;

  ZrtData({
    required this.zoneId,
    required this.regionId,
    required this.territoryId,
  });

  factory ZrtData.fromJson(Map<String, dynamic> json) {
    return ZrtData(
      zoneId: json['zone_id'] ?? '',
      regionId: json['region_id'] ?? '',
      territoryId: json['territory_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'region_id': regionId,
      'territory_id': territoryId,
    };
  }
}
