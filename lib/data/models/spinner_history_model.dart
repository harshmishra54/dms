import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';
 // ✅ Import your existing Segment class

// REQUEST MODEL
class SpinnerHistoryRequest {
  final String id;

  SpinnerHistoryRequest({required this.id});

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

// RESPONSE MODEL
class SpinnerHistoryResponse {
  final int? success;
  final int? total;
  final List<SpinnerHistoryData>? data;

  SpinnerHistoryResponse({
    this.success,
    this.total,
    this.data,
  });

  factory SpinnerHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SpinnerHistoryResponse(
      success: json["success"],
      total: json["total"],
      data: json["data"] == null
          ? []
          : List<SpinnerHistoryData>.from(
          json["data"].map((x) => SpinnerHistoryData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "total": total,
    "data": data?.map((x) => x.toJson()).toList(),
  };
}

// DATA MODEL
class SpinnerHistoryData {
  final String? id;
  final int? consumerType;
  final String? consumerId;
  final String? schemeId;
  final String? productId;
  final String? spinnerId;
  final String? createdAt;
  final String? level;
  final int? points;
  final bool? isUsed;
  final List<Segment>? segments; // ✅ Using existing Segment class

  SpinnerHistoryData({
    this.id,
    this.consumerType,
    this.consumerId,
    this.schemeId,
    this.productId,
    this.spinnerId,
    this.createdAt,
    this.level,
    this.points,
    this.isUsed,
    this.segments,
  });

  factory SpinnerHistoryData.fromJson(Map<String, dynamic> json) {
    return SpinnerHistoryData(
      id: json["id"],
      consumerType: json["consumer_type"],
      consumerId: json["consumer_id"],
      schemeId: json["scheme_id"],
      productId: json["product_id"],
      spinnerId: json["spinner_id"],
      createdAt: json["created_at"],
      level: json["level"],
      points: json["points"],
      isUsed: json["is_used"],
      segments: json["segments"] == null
          ? []
          : List<Segment>.from(
        json["segments"].map((x) => Segment.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "consumer_type": consumerType,
    "consumer_id": consumerId,
    "scheme_id": schemeId,
    "product_id": productId,
    "spinner_id": spinnerId,
    "created_at": createdAt,
    "level": level,
    "points": points,
    "is_used": isUsed,
    "segments": segments?.map((x) => {
      "point": x.point,
      "probability": x.probability,
    }).toList(),

  };
}
