import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/order_list.dart';

class OrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<OrderListDataResponse> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderListDataResponse> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      int? roleId = await SharedPrefsHelper.getRoleId(); // int
      final userId = await SharedPrefsHelper.getUserId(); // string

      if (token == null || roleId == null || userId == null) {
        _error = "Missing token, role ID, or user ID.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ Map role_id: 0 → 1 for distributor
      if (roleId == 0) {
        roleId = 1;
      }

      Map<String, dynamic> body = {
        "role_id": roleId,
        "request_id": userId,
      };

      final response = await _dioClient.post(
        ApiEndpoints.orderlist,
        data: body,
        options: Options(
          headers: {
            "x-access-token": token,
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      debugPrint("*** Request Sent ***");
      debugPrint("Token: $token");
      debugPrint("Role ID (mapped): $roleId");
      debugPrint("User ID: $userId");
      debugPrint("Body: $body");
      debugPrint("*** Response ***");
      debugPrint("Response Data: ${response.data}");

      if (response.data['success'].toString() == "1") {
        final List<dynamic> data = response.data['data'] ?? [];
        _orders = data.map((e) => OrderListDataResponse.fromJson(e)).toList();
      } else {
        _error = response.data['message'] ?? "Failed to load orders.";
      }
    } catch (e) {
      _error = "Error: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }
}

// ✅ Extension added in the same file so it can access private members
extension OrderProviderExtensions on OrderProvider {
  Future<void> fetchOrdersForDistributor(String distributorId, int roleId) async {
    // ✅ Map role_id: 0 → 1 here also
    if (roleId == 0) {
      roleId = 1;
    }

    await _fetchOrdersWithCustomBody({
      "role_id": roleId,
      "request_id": distributorId,
    });
  }

  Future<void> _fetchOrdersWithCustomBody(Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        _error = "Missing token.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.orderlist,
        data: body,
        options: Options(
          headers: {
            "x-access-token": token,
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

      if (response.data['success'].toString() == "1") {
        final List<dynamic> data = response.data['data'] ?? [];
        _orders = data.map((e) => OrderListDataResponse.fromJson(e)).toList();
      } else {
        _error = response.data['message'] ?? "Failed to load orders.";
      }
    } catch (e) {
      _error = "Error: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }
}
