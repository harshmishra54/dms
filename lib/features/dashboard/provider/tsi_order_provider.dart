import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_order_models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TsiOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<OrderTsi> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<OrderTsi> get orders => _orders;

  /// Fetch TSI Orders
  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get saved token & user id from shared preferences
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();
      final roleId=await SharedPrefsHelper.getRoleId();

      if (token == null || userId == null) {
        _errorMessage = "Missing authentication details";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare request body with fixed role_id = "1"
      final requestData = {
        "role_id": roleId, // ✅ Fixed value
        "request_id": userId,
      };

      // Call API
      final response = await _dioClient.post(
        ApiEndpoints.tsiorderdetails,

        data: requestData,
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final tsiResponse = TsiOrderResponse.fromJson(response.data);

        if (tsiResponse.success == 1) {
          _orders = tsiResponse.data;
        } else {
          _errorMessage = "No orders found";
          _orders = [];
        }
      } else {
        _errorMessage = "Failed to fetch orders";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
