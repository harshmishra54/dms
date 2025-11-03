// 📌 add_return_scan_code_models.dart

class AddReturnScanCodePostData {
  final String uniqueCode;
  final String id;

  AddReturnScanCodePostData({required this.uniqueCode,required this.id});

  Map<String, dynamic> toJson() {
    return {
      "uniqueCode": uniqueCode,
      "id": id,
    };
  }
}

class AddReturnScanCodeResponse {
  final int? success;
  final String? message;
  final Data? data;

  AddReturnScanCodeResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AddReturnScanCodeResponse.fromJson(Map<String, dynamic> json) {
    return AddReturnScanCodeResponse(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class Data {
  final String? id;
  final String? productId;
  final String? batchId;
  final String? poId;
  final String? qrCode;
  final String? uniqueCode;
  final String? serialCode;
  final String? parentId;
  final bool? isOpen;
  final bool? isGeneral;
  final String? parentLevel;
  final bool? isMapped;
  final String? mappedToParent;
  final String? mappedAt;
  final String? mappedBy;
  final bool? isDropped;
  final bool? isComplete;
  final String? completedAt;
  final String? completedBy;
  final bool? isScanned;
  final int? storageBinId;
  final String? createdAt;
  final bool? isActive;
  final bool? isReplaced;
  final String? replacedWith;
  final String? replacedFrom;
  final String? replacedWithType;
  final String? replacedAt;
  final String? replacedBy;
  final String? mappTransactionId;
  final String? transactionId;
  final String? mappingPoId;
  final String? assignedProductId;
  final String? assignedBatchId;
  final bool? isBoxOpened;
  final bool? isInConsignment;
  final String? requestId;
  final String? customerId;
  final String? dealerId;
  final String? retailerId;
  final String? customeProductId;
  final String? cpUid;
  final bool? hasParent;
  final String? updatedAt;
  final ProductBatch? productBatch;
  final Product? product;
  final String? level; // ✅ keep as string

  Data({
    this.id,
    this.productId,
    this.batchId,
    this.poId,
    this.qrCode,
    this.uniqueCode,
    this.serialCode,
    this.parentId,
    this.isOpen,
    this.isGeneral,
    this.parentLevel,
    this.isMapped,
    this.mappedToParent,
    this.mappedAt,
    this.mappedBy,
    this.isDropped,
    this.isComplete,
    this.completedAt,
    this.completedBy,
    this.isScanned,
    this.storageBinId,
    this.createdAt,
    this.isActive,
    this.isReplaced,
    this.replacedWith,
    this.replacedFrom,
    this.replacedWithType,
    this.replacedAt,
    this.replacedBy,
    this.mappTransactionId,
    this.transactionId,
    this.mappingPoId,
    this.assignedProductId,
    this.assignedBatchId,
    this.isBoxOpened,
    this.isInConsignment,
    this.requestId,
    this.customerId,
    this.dealerId,
    this.retailerId,
    this.customeProductId,
    this.cpUid,
    this.hasParent,
    this.updatedAt,
    this.productBatch,
    this.product,
    this.level,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      productId: json['product_id'],
      batchId: json['batch_id'],
      poId: json['po_id'],
      qrCode: json['qr_code'],
      uniqueCode: json['unique_code'],
      serialCode: json['serial_code'],
      parentId: json['parent_id'],
      isOpen: json['is_open'] == true || json['is_open'] == 1,
      isGeneral: json['is_general'] == true || json['is_general'] == 1,
      parentLevel: json['parent_level'],
      isMapped: json['is_mapped'] == true || json['is_mapped'] == 1,
      mappedToParent: json['mapped_to_parent'],
      mappedAt: json['mapped_at'],
      mappedBy: json['mapped_by'],
      isDropped: json['is_dropped'] == true || json['is_dropped'] == 1,
      isComplete: json['is_complete'] == true || json['is_complete'] == 1,
      completedAt: json['completed_at'],
      completedBy: json['completed_by'],
      isScanned: json['is_scanned'] == true || json['is_scanned'] == 1,
      storageBinId: json['storage_bin_id'],
      createdAt: json['created_at'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isReplaced: json['is_replaced'] == true || json['is_replaced'] == 1,
      replacedWith: json['replaced_with'],
      replacedFrom: json['replaced_from'],
      replacedWithType: json['replaced_with_type'],
      replacedAt: json['replaced_at'],
      replacedBy: json['replaced_by'],
      mappTransactionId: json['mapp_transaction_id'],
      transactionId: json['transaction_id'],
      mappingPoId: json['mapping_po_id'],
      assignedProductId: json['assigned_product_id'],
      assignedBatchId: json['assigned_batch_id'],
      isBoxOpened: json['is_box_opened'] == true || json['is_box_opened'] == 1,
      isInConsignment:
      json['is_in_consignment'] == true || json['is_in_consignment'] == 1,
      requestId: json['request_id'],
      customerId: json['customer_id'],
      dealerId: json['dealer_id'],
      retailerId: json['retailer_id'],
      customeProductId: json['custome_product_id'],
      cpUid: json['cp_uid'],
      hasParent: json['has_parent'] == true || json['has_parent'] == 1,
      updatedAt: json['updatedAt'],
      productBatch: json['product_batch'] != null
          ? ProductBatch.fromJson(json['product_batch'])
          : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      level: json['level'], // ✅ always string from API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "batch_id": batchId,
      "po_id": poId,
      "qr_code": qrCode,
      "unique_code": uniqueCode,
      "serial_code": serialCode,
      "parent_id": parentId,
      "is_open": isOpen,
      "is_general": isGeneral,
      "parent_level": parentLevel,
      "is_mapped": isMapped,
      "mapped_to_parent": mappedToParent,
      "mapped_at": mappedAt,
      "mapped_by": mappedBy,
      "is_dropped": isDropped,
      "is_complete": isComplete,
      "completed_at": completedAt,
      "completed_by": completedBy,
      "is_scanned": isScanned,
      "storage_bin_id": storageBinId,
      "created_at": createdAt,
      "is_active": isActive,
      "is_replaced": isReplaced,
      "replaced_with": replacedWith,
      "replaced_from": replacedFrom,
      "replaced_with_type": replacedWithType,
      "replaced_at": replacedAt,
      "replaced_by": replacedBy,
      "mapp_transaction_id": mappTransactionId,
      "transaction_id": transactionId,
      "mapping_po_id": mappingPoId,
      "assigned_product_id": assignedProductId,
      "assigned_batch_id": assignedBatchId,
      "is_box_opened": isBoxOpened,
      "is_in_consignment": isInConsignment,
      "request_id": requestId,
      "customer_id": customerId,
      "dealer_id": dealerId,
      "retailer_id": retailerId,
      "custome_product_id": customeProductId,
      "cp_uid": cpUid,
      "has_parent": hasParent,
      "updatedAt": updatedAt,
      "product_batch": productBatch?.toJson(),
      "product": product?.toJson(),
      "level": level,
    };
  }
}

class ProductBatch {
  final String? id;
  final String? batchNo;
  final String? mfgDate;
  final String? mrp;

  ProductBatch({
    this.id,
    this.batchNo,
    this.mfgDate,
    this.mrp,
  });

  factory ProductBatch.fromJson(Map<String, dynamic> json) {
    return ProductBatch(
      id: json['id'],
      batchNo: json['batch_no'],
      mfgDate: json['mfg_date'],
      mrp: json['mrp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "batch_no": batchNo,
      "mfg_date": mfgDate,
      "mrp": mrp,
    };
  }
}

class Product {
  final String? id;
  final String? sku;
  final String? uId;
  final String? name;

  Product({
    this.id,
    this.sku,
    this.uId,
    this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      sku: json['sku'],
      uId: json['u_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "u_id": uId,
      "name": name,
    };
  }
}
