import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/accept_all_items_model.dart';

class AcceptAllItemsProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AcceptAllItemsModelResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AcceptAllItemsModelResponse? get response => _response;

  /// Call API to accept all items
  Future<void> acceptAllItems(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) throw Exception("Missing authentication token");

      final response = await _dioClient.post(
        ApiEndpoints.acceptAllitems, // ✅ Make sure you add this endpoint in ApiEndpoints
        data: {"orderId": orderId},
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      _response = AcceptAllItemsModelResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
