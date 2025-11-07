import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/spinner_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


class SpinnerRewardProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  SpinnerRewardResponse? _rewardResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SpinnerRewardResponse? get rewardResponse => _rewardResponse;

  /// ✅ Call Spinner API
  Future<void> fetchSpinnerPoints(String spinnerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _rewardResponse = null;
      notifyListeners();

      final token = await SharedPrefsHelper.getAccessToken();
      final request = SpinnerRewardRequest(id: spinnerId);

      final response = await _dioClient.post(
        ApiEndpoints.getPointsbySpinning,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? ""
          },
        ),
      );

      if (response.data != null) {
        _rewardResponse = SpinnerRewardResponse.fromJson(response.data);
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
