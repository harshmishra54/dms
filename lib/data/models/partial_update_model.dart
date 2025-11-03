// lib/data/models/partial_order_update_model.dart

class PartialOrderUpdateModel {
  // ✅ Request fields
  final String? id;
  final int? roleId;
  final String? requestId;
  final String? deliveryDate;
  final List<ProductUpdate>? products;

  // ✅ Response fields
  final int? success;
  final String? message;

  PartialOrderUpdateModel({
    this.id,
    this.roleId,
    this.requestId,
    this.deliveryDate,
    this.products,
    this.success,
    this.message,
  });

  // ✅ Convert Request → JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      if (roleId != null) "role_id": roleId,
      if (requestId != null) "request_id": requestId,
      if (deliveryDate != null) "delivery_date": deliveryDate,
      if (products != null)
        "products": products!.map((p) => p.toJson()).toList(),
    };
  }

  // ✅ Parse Response ← JSON
  factory PartialOrderUpdateModel.fromJson(Map<String, dynamic> json) {
    return PartialOrderUpdateModel(
      success: json["success"],
      message: json["message"],
    );
  }
}

class ProductUpdate {
  final String productId;
  final int approvedQty;

  ProductUpdate({
    required this.productId,
    required this.approvedQty,
  });

  Map<String, dynamic> toJson() {
    return {
      "product_id": productId,
      "approved_qty": approvedQty,
    };
  }
}
