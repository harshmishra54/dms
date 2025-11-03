import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/all_stock_inventory_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class AllFocusNewProductStockProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  Map<String, FocusProductStockData?> _stockMap = {};
  Map<String, FocusProductStockData?> get stockMap => _stockMap;

  Map<String, bool> _isLoadingMap = {};
  Map<String, bool> get isLoadingMap => _isLoadingMap;

  Map<String, String?> _errorMap = {};
  Map<String, String?> get errorMap => _errorMap;


  Future<void> fetchFocusProductStock(String locationId, {bool forceRefresh = false}) async {
    // if (_isLoadingMap[locationId] == true) return;

    // Skip only if already fetched and no forceRefresh
    // if (!forceRefresh && _stockMap.containsKey(locationId)) return;

    _isLoadingMap[locationId] = true;
    _errorMap[locationId] = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final request = FocusProductStockRequest(locationId: locationId);
      final options = Options(headers: {'x-access-token': token ?? ''});

      final response = await _dioClient.post(
        ApiEndpoints.getfocusnewandbestProductstock,
        data: request.toJson(),
        options: options,
      );

      if (response.statusCode == 200) {
        final res = FocusProductStockResponse.fromJson(response.data);
        if (res.success == 1) {
          _stockMap[locationId] = res.data;
        } else {
          _stockMap[locationId] = FocusProductStockData(F: 0, B: 0, S: 0);
          _errorMap[locationId] = res.message;
        }
      } else {
        _stockMap[locationId] = FocusProductStockData(F: 0, B: 0, S: 0);
        _errorMap[locationId] = "Failed to fetch data. Status: ${response.statusCode}";
      }
    } catch (e) {
      _stockMap[locationId] = FocusProductStockData(F: 0, B: 0, S: 0);
      _errorMap[locationId] = e.toString();
    } finally {
      _isLoadingMap[locationId] = false;
      notifyListeners();
    }
  }

}
