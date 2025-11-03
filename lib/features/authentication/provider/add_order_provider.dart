import 'package:TrustTags_DMS/data/models/add_order_request.dart';
import 'package:TrustTags_DMS/data/models/add_order_response.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

import 'package:dio/dio.dart';

class AddOrderProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  AddOrderResponse? _response;

  bool get isLoading => _isLoading;
  String? get error => _error;
  AddOrderResponse? get response => _response;

  final DioClient _dioClient = DioClient();

  Future<void> submitOrder(AddOrderRequest requestModel) async {
    _isLoading = true;
    _error = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.addOrder, // ✅ using constant
        data: requestModel.toJson(),
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );


      _response = AddOrderResponse.fromJson(response.data);
    } catch (e) {
      _error = "Something went wrong while placing the order.";
      if (e is DioException) {
        _error = e.response?.data["message"] ?? _error;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _error = null;
    _response = null;
    notifyListeners();
  }
}
