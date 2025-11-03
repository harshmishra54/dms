import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/return_order_details_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ReturnOrderDetailsProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  DetailsOrderListResponse? _orderDetails;
  DetailsOrderListResponse? get orderDetails => _orderDetails;

  /// Fetch details of one return order
  Future<void> fetchReturnOrderDetails({
    required String orderId,
    required String roleId,
    required String requestId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.DetailsReturnOrder,
        data: {
          "id": orderId,
          "role_id": roleId,
          "request_id": requestId,
        },
        options: Options(headers: {
          "x-access-token": token ?? "",
        }),
      );

      final result = DetailsOrderListResponse.fromJson(response.data);
      if (result.success == 1) {
        _orderDetails = result;
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _orderDetails = null;
    _error = null;
    notifyListeners();
  }
}
