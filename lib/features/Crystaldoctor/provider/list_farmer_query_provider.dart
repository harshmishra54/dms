// file: list_farmer_query_provider.dart

import 'package:TrustTags_DMS/data/models/list_farmer_query_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class ListFarmerQueryProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<FarmerQueryData> _farmerQueries = [];
  bool _isLoading = false;
  String? _error;

  List<FarmerQueryData> get farmerQueries => _farmerQueries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch farmer queries API
  Future<void> fetchFarmerQueries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // ✅ Get user id from SharedPreferences
      String? userId = await SharedPrefsHelper.getUserId();
      String? token = await SharedPrefsHelper.getAccessToken();

      if (userId == null || token == null) {
        _error = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ Prepare request body
      final requestBody = ListFarmerQueryRequest(createdBy: userId).toJson();

      // ✅ Send POST request with x-access-token
      Response response = await _dioClient.post(
        ApiEndpoints.listfarmerquery,
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final respModel = ListFarmerQueryResponse.fromJson(response.data);
        _farmerQueries = respModel.data;
      } else {
        _error = "Failed to fetch data. Status code: ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Optional: clear data
  void clearData() {
    _farmerQueries = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
