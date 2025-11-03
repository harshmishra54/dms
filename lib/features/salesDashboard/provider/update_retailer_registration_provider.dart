// update_retail_rsm_provider.dart

import 'package:TrustTags_DMS/data/models/update_distributor_registration_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class UpdateRetailerRsmProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  Future<bool> updateRetailerStatus({
    required String id,
    required bool status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _message = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Prepare request model
      final request = UpdateRetailerStatusRequest(id: id, status: status);

      // Call API
      final response = await _dioClient.client.post(
        ApiEndpoints.approveretailerregistration,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final resModel = UpdateRetailerStatusResponse.fromJson(response.data);
        _message = resModel.message;
        _isLoading = false;
        notifyListeners();
        return resModel.success == 1;
      } else {
        _message = "Something went wrong. Please try again.";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
