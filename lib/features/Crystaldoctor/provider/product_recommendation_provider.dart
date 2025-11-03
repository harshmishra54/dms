import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/product_recommendation_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
class ProductRecommendationProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String _errorMessage = '';
  ProductRecommendationResponse? _response;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ProductRecommendationResponse? get response => _response;

  Future<void> recommendProducts(ProductRecommendationRequestbody request) async {
    _isLoading = true;
    _errorMessage = '';
    _response = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        _errorMessage = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final headers = {
        'x-access-token': token,
        'Content-Type': 'application/json',
      };

      final response = await _dioClient.post(
        ApiEndpoints.productrecommendtofarmer,
        data: request.toJson(),
        options: Options(headers: headers),
      );

      // Parse API response
      _response = ProductRecommendationResponse.fromJson(response.data);
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
