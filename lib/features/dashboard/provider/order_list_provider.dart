import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_list.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class OrderListProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  OrderListResponse? _orderListResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  OrderListResponse? get orderListResponse => _orderListResponse;

  /// Fetch order list from API
  Future<void> fetchOrderList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 🔹 Get token & requestId from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();
      final requestId = await SharedPrefsHelper.getUserId();

      if (token == null || requestId == null || requestId.isEmpty) {
        _errorMessage = "User not logged in or missing requestId";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // 🔹 roleId is always "1" (String)
      final request = OrderListRequest(
        roleId: "1",
        requestId: requestId,
      );

      final response = await _dioClient.post(
        ApiEndpoints.reciveOrderList,
        data: request.toJson(),
        options: Options(headers: {
          "x-access-token": token,
        }),
      );

      // 🔎 Debug log to inspect actual API response
      if (kDebugMode) {
        print("📡 Request: ${request.toJson()}");
        print("📡 Response Status: ${response.statusCode}");
        print("📡 Response Data: ${response.data}");
      }

      if (response.statusCode == 200) {
        _orderListResponse = OrderListResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed with status: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
      if (kDebugMode) {
        print("❌ API Error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear state (optional, for refreshing)
  void clear() {
    _orderListResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
