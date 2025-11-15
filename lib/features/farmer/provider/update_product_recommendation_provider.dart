import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:dio/dio.dart';

class UpdateRecommendationProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? get responseData => _responseData;

  /// --------------------------------------------------------
  /// 🔥 CALL UPDATE RECOMMENDATION API
  /// --------------------------------------------------------
  Future<bool> updateRecommendation({
    required String queryId,
    required bool interestedIn,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final body = {
        "query_id": queryId,
        "interested_in": interestedIn,
      };

      final response = await _dioClient.post(
        ApiEndpoints.updateproductrecommendation,
        data: body,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200 && response.data["success"] == 1) {
        _responseData = response.data;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.data["message"] ?? "Something went wrong";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
