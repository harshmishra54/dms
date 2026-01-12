import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/focus_product_request.dart';
import 'package:TrustTags_DMS/data/models/focus_product_response.dart';
import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';
import 'package:TrustTags_DMS/features/authentication/provider/order_product_provider.dart';
import 'package:TrustTags_DMS/data/models/focus_product_mapper.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class FocusProductProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();
  final OrderProductProvider orderProductProvider;

  FocusProductProvider(this.orderProductProvider);

  final Map<int, List<OrderProductListDataResponse>> _productsByType = {};
  bool _isLoading = false;
  String? _error;

  List<OrderProductListDataResponse> getProducts(int type) =>
      _productsByType[type] ?? [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch Products by Type (1 = Focus, 2 = Seasonal, 3 = Scheme)
  Future<void> fetchProducts(int type, {required String locationId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();
      bool isDistributor = false;

      final intRoleId = int.tryParse(roleId?.toString() ?? '') ?? 0;


      if (intRoleId >= 18) {
        // Higher roles → depend on daily role
        final dailyRoleId = await SharedPrefsHelper.getDailyRoleId();
        isDistributor = dailyRoleId == "1";
      } else if (intRoleId == 1) {
        // Distributor role
        isDistributor = true;
      }


      final response = await _dioClient.post(
        ApiEndpoints.focusProduct,
        data: FocusProductRequest(
          locationId: locationId,
          type: type.toString(),
          isDistributor: isDistributor,
        ).toJson(),
        options: Options(headers: {"x-access-token": token}),
      );

      final parsed = FocusProductResponse.fromJson(response.data);

      if (parsed.success == 1) {
        final allProducts = orderProductProvider.products;

        // 🔥 Match focus SKUs to order product item_code
        final matched = parsed.data.map((fp) {
          final match = allProducts.firstWhere(
                (p) => p.itemCode == fp.sku, // ✅ correct mapping
            orElse: () =>
                OrderProductListDataResponse(
                  id: fp.id,
                  itemCode: fp.sku,
                  productName: '',
                  price: 0.0,
                  schemePrice: 0.0,
                  purchasePrice:0.0,
                  distributorId: '',
                ),
          );
          return fp.toOrderProduct(fullProduct: match);
        }).toList();

        _productsByType[type] = matched;
      } else {
        _productsByType[type] = [];
        _error = "Failed to fetch focus products";
      }
    } catch (e) {
      _productsByType[type] = [];
      _error = e.toString();
      debugPrint("❌ FocusProductProvider error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }}