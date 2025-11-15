class GetCfaStockRequest {
  final String userId;

  GetCfaStockRequest({required this.userId});

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
    };
  }
}
class GetCfaStockResponse {
  final int success;
  final String message;
  final List<LocationStock> data;

  GetCfaStockResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetCfaStockResponse.fromJson(Map<String, dynamic> json) {
    return GetCfaStockResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null
          ? List<LocationStock>.from(
          json['data'].map((x) => LocationStock.fromJson(x)))
          : [],
    );
  }
}

class LocationStock {
  final String locationId;
  final String locationName;
  final List<Stock> stocks;

  LocationStock({
    required this.locationId,
    required this.locationName,
    required this.stocks,
  });

  factory LocationStock.fromJson(Map<String, dynamic> json) {
    return LocationStock(
      locationId: json['location_id'],
      locationName: json['location_name'],
      stocks: json['stocks'] != null
          ? List<Stock>.from(json['stocks'].map((x) => Stock.fromJson(x)))
          : [],
    );
  }
}

class Stock {
  final String id;
  final int qty;
  final String packagingLevel;
  final String createdAt;
  final Product? product;
  final Batch? batch;
  final Bin bin;

  Stock({
    required this.id,
    required this.qty,
    required this.packagingLevel,
    required this.createdAt,
    this.product,
    this.batch,
    required this.bin,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      qty: json['qty'],
      packagingLevel: json['packaging_level'],
      createdAt: json['createdAt'],
      product:
      json['product'] != null ? Product.fromJson(json['product']) : null,
      batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
      bin: Bin.fromJson(json['bin']),
    );
  }
}

class Product {
  final String name;
  final String sku;
  final int size;
  final String standardUnit;

  Product({
    required this.name,
    required this.sku,
    required this.size,
    required this.standardUnit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      sku: json['sku'],
      size: json['size'],
      standardUnit: json['standard_unit'] ?? '',
    );
  }
}

class Batch {
  final String mfgDate;
  final String batchNo;

  Batch({
    required this.mfgDate,
    required this.batchNo,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      mfgDate: json['mfg_date'],
      batchNo: json['batch_no'],
    );
  }
}

class Bin {
  final int id;
  final String name;
  final bool isDefaultBin;

  Bin({
    required this.id,
    required this.name,
    required this.isDefaultBin,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'],
      name: json['name'],
      isDefaultBin: json['is_default_bin'],
    );
  }
}
