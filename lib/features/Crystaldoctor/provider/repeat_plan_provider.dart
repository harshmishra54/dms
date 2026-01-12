import 'package:TrustTags_DMS/data/models/repeat_beat_plan.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';


class RepeatPlanProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false; // keep for internal logic if needed
  bool _isRepeating = false; // ✅ NEW FLAG

  String? _errorMessage;
  RepeatPlanResponse? _response;

  bool get isLoading => _isLoading;
  bool get isRepeating => _isRepeating; // ✅ expose this
  String? get errorMessage => _errorMessage;
  RepeatPlanResponse? get response => _response;

  /// ✅ Repeat Beat Plan API
  Future<bool> repeatPlan({
    required RepeatPlanRequest request,
  }) async {
    // 🔥 THIS IS THE KEY PART
    _isRepeating = true;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.post(
        ApiEndpoints.repeatBeatplan,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        final resData = RepeatPlanResponse.fromJson(response.data);
        _response = resData;

        if (resData.success == 1) {
          _isRepeating = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = resData.message;
        }
      } else {
        _errorMessage = "Server returned ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    }

    _isRepeating = false;
    notifyListeners();
    return false;
  }

  void clear() {
    _isLoading = false;
    _isRepeating = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}

