import 'dart:convert';
import 'package:TrustTags_DMS/data/models/product_catalogue_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class ProductCatalogueProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductData> _products = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductData> get products => _products;

  /// ✅ Fetch product catalogue from API
  Future<void> fetchProductCatalogue() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.get(
        ApiEndpoints.producutCatalogue,
        options: Options(
          headers: {
            'x-access-token': token ?? '',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = ProductCatalogueResponse.fromJson(response.data);
        _products = data.data;
      } else {
        _errorMessage =
        'Failed to fetch catalogue. Code: ${response.statusCode}';
      }
    } catch (e, stack) {
      debugPrint('⚠️ Error in fetchProductCatalogue: $e\n$stack');
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🧹 Optional: Clear data when refreshing or logging out
  void clear() {
    _products = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
