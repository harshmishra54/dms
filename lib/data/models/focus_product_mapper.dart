import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';
import 'focus_product_response.dart';

extension FocusProductMapper on FocusProduct {
  OrderProductListDataResponse toOrderProduct({
    OrderProductListDataResponse? fullProduct,
  }) {
    return OrderProductListDataResponse(
      id: id,
      itemCode: fullProduct?.itemCode ?? sku, // ✅ sku ↔ item_code
      productName: fullProduct?.productName ?? '',
      price: fullProduct?.price ?? 0.0,
      schemePrice: fullProduct?.schemePrice ?? 0.0,
      purchasePrice: fullProduct?.purchasePrice?? 0.0,
      distributorId: fullProduct?.distributorId ?? '',
    );
  }
}
