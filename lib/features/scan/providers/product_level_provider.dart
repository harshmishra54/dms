import 'package:TrustTags_DMS/features/scan/models/product_level_check_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class ProductLevelProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  ProductLevelResponse? _productLevelResponse;
  ProductLevelResponse? get productLevelResponse => _productLevelResponse;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// ✅ Method to call the check-product-level API
  Future<void> checkProductLevel(ProductLevelRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      String? token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _errorMessage = "User token not found. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.client.post(
        ApiEndpoints.checkProductLevel,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200) {
        _productLevelResponse = ProductLevelResponse.fromJson(response.data);
      } else {
        _errorMessage = "Error: ${response.statusCode}";
      }
    } on DioException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optional: Reset provider state
  void reset() {
    _productLevelResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
