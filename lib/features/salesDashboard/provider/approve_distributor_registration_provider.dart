import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/update_distributor_approval_by_rsm_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
// import your request & response model

class UpdateDistributorProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UpdateDistributorStatusResponse? _response;
  UpdateDistributorStatusResponse? get response => _response;

  String? _error;
  String? get error => _error;

  /// Update Distributor Status
  Future<void> updateDistributorStatus({
    required String id,
    required bool status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        _error = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Prepare request body
      final request = UpdateDistributorStatusRequest(id: id, status: status);

      final response = await _dioClient.client.post(
        ApiEndpoints.approvedistributorregistration,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _response = UpdateDistributorStatusResponse.fromJson(response.data);
      } else {
        _error = "Something went wrong: ${response.statusCode}";
      }
    } on DioException catch (e) {
      _error = e.message ?? "Something went wrong";
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
