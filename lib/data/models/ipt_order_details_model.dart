// file: ipt_order_details_model.dart

/// Request Model
class IptOrderDetailsRequest {
  final String orderId;

  IptOrderDetailsRequest({required this.orderId});

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
    };
  }
}

/// Response Model
class IptOrderDetailsResponse {
  final int success;
  final IptOrderData? data;

  IptOrderDetailsResponse({required this.success, this.data});

  factory IptOrderDetailsResponse.fromJson(Map<String, dynamic> json) {
    return IptOrderDetailsResponse(
      success: json['success'],
      data: json['data'] != null ? IptOrderData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class IptOrderData {
  final Order? order;
  final List<IptOrderLineItem>? lineItems;

  IptOrderData({this.order, this.lineItems});

  factory IptOrderData.fromJson(Map<String, dynamic> json) {
    return IptOrderData(
      order: json['order'] != null ? Order.fromJson(json['order']) : null,
      lineItems: json['lineItems'] != null
          ? List<IptOrderLineItem>.from(
          json['lineItems'].map((x) => IptOrderLineItem.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'lineItems': lineItems?.map((x) => x.toJson()).toList(),
    };
  }
}

class Order {
  final String? id;
  final String? name;
  final String? fromLocation;
  final String? toLocation;
  final String? cfaLocation;
  final String? invoiceNo;
  final String? orderNo;
  final String? price;
  final String? uId;
  final String? status;
  final bool? isPartial;
  final bool? isCustomer;
  final String? territoryId;
  final DateTime? orderDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.name,
    this.fromLocation,
    this.toLocation,
    this.cfaLocation,
    this.invoiceNo,
    this.orderNo,
    this.price,
    this.uId,
    this.status,
    this.isPartial,
    this.isCustomer,
    this.territoryId,
    this.orderDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      name: json['name'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      cfaLocation: json['cfa_location'],
      invoiceNo: json['invoice_no'],
      orderNo: json['order_no'],
      price: json['price'],
      uId: json['u_id'],
      status: json['status'],
      isPartial: json['is_partial'],
      isCustomer: json['is_customer'],
      territoryId: json['territory_id'],
      orderDate: json['order_date'] != null
          ? DateTime.parse(json['order_date'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'from_location': fromLocation,
      'to_location': toLocation,
      'cfa_location': cfaLocation,
      'invoice_no': invoiceNo,
      'order_no': orderNo,
      'price': price,
      'u_id': uId,
      'status': status,
      'is_partial': isPartial,
      'is_customer': isCustomer,
      'territory_id': territoryId,
      'order_date': orderDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class IptOrderLineItem {
  final String? id;
  final String? orderId;
  final String? productId;
  final String? level;
  final String? batchId;
  final String? qty;
  final String? uniqueCode;
  final String? price;
  final String? schemePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? IptProductName;

  IptOrderLineItem({
    this.id,
    this.orderId,
    this.productId,
    this.level,
    this.batchId,
    this.qty,
    this.uniqueCode,
    this.price,
    this.schemePrice,
    this.createdAt,
    this.updatedAt,
    this.IptProductName
  });

  factory IptOrderLineItem.fromJson(Map<String, dynamic> json) {
    return IptOrderLineItem(
      id: json['id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      level: json['level'],
      batchId: json['batch_id'],
      qty: json['qty'],
      uniqueCode: json['unique_code'],
      price: json['price'],
      schemePrice: json['scheme_price'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      IptProductName: json['product_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'level': level,
      'batch_id': batchId,
      'qty': qty,
      'unique_code': uniqueCode,
      'price': price,
      'scheme_price': schemePrice,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'product_name': IptProductName,
    };
  }
}
