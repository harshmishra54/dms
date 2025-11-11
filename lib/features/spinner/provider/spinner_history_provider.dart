import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/spinner_history_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
 // Your model import

class SpinnerHistoryProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String _error = "";
  List<SpinnerHistoryData> _spinnerHistory = [];

  bool get isLoading => _isLoading;
  String get error => _error;
  List<SpinnerHistoryData> get spinnerHistory => _spinnerHistory;

  /// ✅ FETCH SPINNER HISTORY API
  Future<void> getSpinnerHistory(String consumerId) async {
    try {
      _isLoading = true;
      _error = "";
      notifyListeners();

      final token = await SharedPrefsHelper.getAccessToken();

      final reqModel = SpinnerHistoryRequest(id: consumerId);

      final response = await _dioClient.post(
        ApiEndpoints.spinnerhistory,
        data: reqModel.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.data != null) {
        final resModel = SpinnerHistoryResponse.fromJson(response.data);

        if (resModel.success == 1) {
          _spinnerHistory = resModel.data ?? [];
        } else {
          _error = "Failed to load spinner history";
        }
      } else {
        _error = "Empty response from server";
      }
    } catch (e) {
      _error = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
