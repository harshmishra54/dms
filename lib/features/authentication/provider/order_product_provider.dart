import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/order_product_list_data_response.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/order_list_request.dart';
import 'package:TrustTags_DMS/data/models/order_product_list_response.dart';


class OrderProductProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<OrderProductListDataResponse> _products = [];
  List<OrderProductListDataResponse> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchOrderProductList({
    String? distributorId,
    String? requestIdOverride,
    String? roleIdOverride,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      String roleId = roleIdOverride ?? (await SharedPrefsHelper.getRoleId())?.toString() ?? "";
      String? requestId = requestIdOverride;

      if (requestId == null) {
        // keep old behavior if no override is passed
        if (roleId == "18") {
          requestId = await SharedPrefsHelper.getDailylocationIdKey();
          debugPrint("TSI User detected, requestId = $requestId");
        } else if (roleId == "3") {
          requestId = distributorId;
          debugPrint("Distributor User detected, requestId = $requestId");
        } else {
          requestId = await SharedPrefsHelper.getUserId();
          debugPrint("Normal User detected, requestId = $requestId");
        }
      }

      if (token == null || token.isEmpty || roleId.isEmpty || requestId == null || requestId.isEmpty) {
        debugPrint("Missing token, roleId, or requestId");
        _products = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = OrderListRequest(
        roleId: roleId,
        requestId: requestId,
      );

      final response = await _dioClient.post(
        ApiEndpoints.orderProductList,
        data: request.toJson(),
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      final parsedResponse = OrderProductListResponse.fromJson(response.data);

      if (parsedResponse.success == 1) {
        _products = parsedResponse.data;
      } else {
        _products = [];
      }
    } catch (e) {
      debugPrint("Error fetching order product list: $e");
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

}
