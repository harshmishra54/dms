class CropResponse {
  final int success;
  final List<CropData> data;

  CropResponse({
    required this.success,
    required this.data,
  });

  factory CropResponse.fromJson(Map<String, dynamic> json) {
    List<CropData> allCrops = [];

    if (json['data'] != null) {
      // handle grouped data like { "Rabi": [...], "Kharif": [...] }
      final data = json['data'] as Map<String, dynamic>;

      data.forEach((season, crops) {
        for (var item in crops) {
          allCrops.add(CropData.fromJson({
            ...item,
            'season': season, // attach season info
          }));
        }
      });
    }

    return CropResponse(
      success: json['success'] ?? 0,
      data: allCrops,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class CropData {
  final String id;
  final String cropTypeId;
  final String cropTypeName;
  final String? season; // optional field added

  CropData({
    required this.id,
    required this.cropTypeId,
    required this.cropTypeName,
    this.season,
  });

  factory CropData.fromJson(Map<String, dynamic> json) {
    return CropData(
      id: json['id'] ?? '',
      cropTypeId: json['crop_type_id'] ?? '',
      cropTypeName: json['crop_type_name'] ?? '',
      season: json['season'], // added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_type_id': cropTypeId,
      'crop_type_name': cropTypeName,
      'season': season,
    };
  }
}
