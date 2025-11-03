// recommended_products_provider.dart

import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/get_recommendation_by_crystal_doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class RecommendedProductsProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  RecommendedProductsResponse? _recommendedProducts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendedProductsResponse? get recommendedProducts => _recommendedProducts;

  /// Fetch recommended products for a given farmer ID
  Future<void> fetchRecommendedProducts(String farmerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        _errorMessage = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare headers
      final options = Options(
        headers: {
          'x-access-token': token,
          'Content-Type': 'application/json',
        },
      );

      // Prepare request body
      final requestBody = GetRecommendedProductsRequest(id: farmerId).toJson();

      // Call API
      final response = await _dioClient.post(
        ApiEndpoints.getrecommendationbycrystaldoctor,
        data: requestBody,
        options: options,
      );

      // Parse response
      _recommendedProducts =
          RecommendedProductsResponse.fromJson(response.data);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear provider state
  void clear() {
    _recommendedProducts = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
