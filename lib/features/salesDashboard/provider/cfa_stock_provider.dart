import 'package:TrustTags_DMS/data/models/cfa_stock_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
// import the request/response models
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class CfaStockProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _loading = false;
  String? _error;
  List<LocationStock> _stockData = [];

  bool get loading => _loading;
  String? get error => _error;
  List<LocationStock> get stockData => _stockData;

  /// ✅ Fetch CFA stock data
  Future<void> fetchCfaStock() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Get userId and token from SharedPrefs
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAccessToken();

      if (userId == null || token == null) {
        _error = "User not logged in";
        _loading = false;
        notifyListeners();
        return;
      }

      final requestBody = GetCfaStockRequest(userId: userId);

      final response = await _dioClient.client.post(
        ApiEndpoints.cnfstock,
        data: requestBody.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final parsedData = GetCfaStockResponse.fromJson(response.data);
        if (parsedData.success == 1) {
          _stockData = parsedData.data;
        } else {
          _error = parsedData.message;
        }
      } else {
        _error = "Failed to fetch data: ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  /// Optional: Clear existing data
  void clearData() {
    _stockData = [];
    _error = null;
    notifyListeners();
  }
}
