import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_list_request.dart';
import 'package:TrustTags_DMS/data/models/to_location_response.dart';

class DistributorProviders with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<DistributorData> _distributors = [];
  List<DistributorData> get distributors => _distributors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDistributors() async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();

      if (token == null || roleId == null) {
        throw Exception("Token or user info not available");
      }

      String requestId;
      String finalRoleId = roleId.toString(); // default roleId

      debugPrint('Role ID from shared prefs: $roleId');

      if (roleId == 18) {
        // If role is TSI (18), use saved location ID from shared preferences
        requestId = await SharedPrefsHelper.getDailylocationIdKey() ?? '';
        debugPrint('Location ID from shared prefs: $requestId');
        if (requestId.isEmpty) {
          // fallback if location id is not set
          requestId = await SharedPrefsHelper.getUserId() ?? '';
          debugPrint('Fallback User ID used as request ID: $requestId');
        }

        // ✅ Extra condition: check dailyRoleId
        final dailyRoleId = await SharedPrefsHelper.getDailyRoleId();
        debugPrint("Fetched dailyRoleId: $dailyRoleId");

        if (dailyRoleId == "3") {
          finalRoleId = "3"; // override roleId
          debugPrint("dailyRoleId is 3 → Overriding roleId to 3");
        }

      } else {
        // For other roles, use userId as usual
        requestId = await SharedPrefsHelper.getUserId() ?? '';
        debugPrint('User ID used as request ID: $requestId');
      }

      final request = OrderListRequest(
        roleId: finalRoleId,
        requestId: requestId,
      );

      debugPrint(
          'Final request payload: roleId=${request.roleId}, requestId=${request.requestId}');

      final response = await _dioClient.post(
        ApiEndpoints.orderlistToLocation,
        data: request.toJson(),
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == 1) {
        final result = ToLocationResponse.fromJson(response.data);
        _distributors = result.data;
      } else {
        _distributors = [];
        debugPrint("Distributor fetch failed: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error fetching distributors: $e");
      _distributors = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
