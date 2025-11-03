import 'package:TrustTags_DMS/data/models/rsm_approve_update_order_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class RsmUpdateOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateOrderByRSMResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateOrderByRSMResponse? get response => _response;

  /// 🔥 Call API
  Future<void> updateOrderByRsm(RsmApproveUpdateOrderModelRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final res = await _dioClient.post(
        ApiEndpoints.updateorderbyrsm,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      _response = UpdateOrderByRSMResponse.fromJson(res.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
