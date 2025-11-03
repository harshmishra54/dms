// dist_stock_models.dart

import 'dart:convert';

/// ===================
/// Request Model
/// ===================
class DistStockRequest {
  final String exportType;
  final String locationId;

  DistStockRequest({
    required this.exportType,
    required this.locationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'exportType': exportType,
      'locationId': locationId,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}

/// ===================
/// Response Model
/// ===================
class DistStockResponse {
  final int success;
  final List<DistStockItem> data;
  final String? fileName;

  DistStockResponse({
    required this.success,
    required this.data,
    this.fileName,
  });

  factory DistStockResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;

    return DistStockResponse(
      success: json['success'] ?? 0,
      data: dataList != null
          ? dataList.map((item) => DistStockItem.fromJson(item)).toList()
          : [], // ✅ safe default
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
      'fileName': fileName,
    };
  }
}

/// ===================
/// Stock Item Model
/// ===================
class DistStockItem {
  final String locationId;
  final String itemCode;
  final String batchNo;
  final String packagingLevel;
  final String bin;
  final int quantity;

  DistStockItem({
    required this.locationId,
    required this.itemCode,
    required this.batchNo,
    required this.packagingLevel,
    required this.bin,
    required this.quantity,
  });

  factory DistStockItem.fromJson(Map<String, dynamic> json) {
    return DistStockItem(
      locationId: json['Location ID'] ?? '',
      itemCode: json['Item Code'] ?? '',
      batchNo: json['Batch No.'] ?? '',
      packagingLevel: json['Packaging Level'] ?? '',
      bin: json['Bin'] ?? '',
      quantity: json['Quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Location ID': locationId,
      'Item Code': itemCode,
      'Batch No.': batchNo,
      'Packaging Level': packagingLevel,
      'Bin': bin,
      'Quantity': quantity,
    };
  }
}
