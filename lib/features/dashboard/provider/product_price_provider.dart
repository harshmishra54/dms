import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/product_price_model.dart';

class AddProductPriceProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UpdateResponse? _updateResponse;
  UpdateResponse? get updateResponse => _updateResponse;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ✅ Store server products for validation
  List<ProductPrice> _serverProductList = [];
  List<ProductPrice> get serverProductList => _serverProductList;

  /// 🔁 Fetch products from server
  Future<void> fetchServerProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _errorMessage = "Authentication token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.get(
        ApiEndpoints.addproductprice, // replace with actual endpoint
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        _serverProductList =
            data.map((e) => ProductPrice.fromExcelRow(e)).toList();
      } else {
        _errorMessage =
        "Unexpected response: ${response.statusCode} - ${response.statusMessage}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Adds product prices for distributor
  Future<void> addProductPrice(List<ProductPrice> productList) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _errorMessage = "Authentication token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final data = {
        "products": productList.map((e) => e.toJson()).toList(),
      };

      final response = await _dioClient.post(
        ApiEndpoints.addproductprice,
        data: data,
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        _updateResponse = UpdateResponse.fromJson(response.data);
      } else {
        _errorMessage =
        "Unexpected response: ${response.statusCode} - ${response.statusMessage}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 🔁 Reset state (optional)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _updateResponse = null;
    notifyListeners();
  }
}
