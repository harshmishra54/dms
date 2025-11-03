// file: lib/features/ipt_order/provider/add_ipt_order_provider.dart

import 'package:TrustTags_DMS/data/models/ipt_add_order_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class AddIPTOrderProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddIPTResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddIPTResponse? get response => _response;

  /// Add IPT Order API
  Future<void> addIptOrder(AddIPTOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final res = await _dioClient.post(
        ApiEndpoints.iptaddorder,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (res.statusCode == 200) {
        _response = AddIPTResponse.fromJson(res.data);
      } else {
        _errorMessage = "Failed with status: ${res.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
