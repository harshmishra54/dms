// lib/features/punchout/provider/punchout_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/punch_out_model.dart';

class PunchOutProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  PunchOutResponse? _punchOutResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PunchOutResponse? get punchOutResponse => _punchOutResponse;

  Future<void> submitPunchOut({
    required String userId,
    required String conclusion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      debugPrint("Token: $token");
      if (token == null) {
        throw Exception("No access token found");
      }

      final request = PunchOutRequest(userId: userId, conclusion: conclusion);
      debugPrint("PunchOut Request: ${request.toJson()}");

      final response = await _dioClient.post(
        ApiEndpoints.punchout,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "x-access-token": token,
          },
        ),
      );

      debugPrint("PunchOut Response: ${response.data}");
      _punchOutResponse = PunchOutResponse.fromJson(response.data);
    } on DioException catch (dioError) {
      debugPrint("Dio Error: ${dioError.response?.data ?? dioError.message}");
      _errorMessage = dioError.response?.data.toString() ?? dioError.message;
    } catch (e) {
      debugPrint("General Error: $e");
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
