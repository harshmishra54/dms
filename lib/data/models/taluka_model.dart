// Request model
class TalukaRequest {
  String territoryId;
  String districtId;

  TalukaRequest({
    required this.territoryId,
    required this.districtId,
  });

  Map<String, dynamic> toJson() {
    return {
      'territoryId': territoryId,
      'districtId': districtId,
    };
  }
}

// Response model
class TalukaResponse {
  int success;
  String message;
  List<TalukaData> data;

  TalukaResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TalukaResponse.fromJson(Map<String, dynamic> json) {
    return TalukaResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => TalukaData.fromJson(e))
          .toList(),
    );
  }
}

class TalukaData {
  int id;
  String name;

  TalukaData({required this.id, required this.name});

  factory TalukaData.fromJson(Map<String, dynamic> json) {
    return TalukaData(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
