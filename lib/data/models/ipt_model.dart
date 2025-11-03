class IptOrderListRequest {
  bool isReceived;
  String requestId;

  IptOrderListRequest({
    this.isReceived = false,
    this.requestId = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'is_received': isReceived,
      'request_id': requestId,
    };
  }
}

class IptOrderListResponse {
  int success;
  List<IptOrderData> data;

  IptOrderListResponse({
    required this.success,
    required this.data,
  });

  factory IptOrderListResponse.fromJson(Map<String, dynamic> json) {
    var list = <IptOrderData>[];
    if (json['data'] != null) {
      list = List<Map<String, dynamic>>.from(json['data'])
          .map((e) => IptOrderData.fromJson(e))
          .toList();
    }
    return IptOrderListResponse(
      success: json['success'] ?? 0,
      data: list,
    );
  }
}

class IptOrderData {
  String? id;
  String? name;
  String? fromLocation;
  String? toLocation;
  String? cfaLocation;
  String? invoiceNo;
  String? orderNo;
  String? uId;
  String? price;
  String? status;
  bool? isPartial;
  String? isCustomer;
  String? territoryId;
  String? orderDate;
  String? createdAt;
  String? updatedAt;

  IptOrderData({
    this.id,
    this.name,
    this.fromLocation,
    this.toLocation,
    this.cfaLocation,
    this.invoiceNo,
    this.orderNo,
    this.uId,
    this.price,
    this.status,
    this.isPartial,
    this.isCustomer,
    this.territoryId,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
  });

  factory IptOrderData.fromJson(Map<String, dynamic> json) {
    return IptOrderData(
      id: json['id'],
      name: json['name'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      cfaLocation: json['cfa_location'],
      invoiceNo: json['invoice_no'],
      orderNo: json['order_no'],
      uId: json['u_id'],
      price: json['price'],
      status: json['status'],
      isPartial: json['is_partial'],
      isCustomer: json['is_customer'],
      territoryId: json['territory_id'],
      orderDate: json['order_date'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
