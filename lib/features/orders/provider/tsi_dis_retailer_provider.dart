import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/shared_prefs_helper.dart';

class TsiDisRetailerProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _responseData;
  Map<String, dynamic>? get responseData => _responseData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final DioClient _dioClient = DioClient();

  /// ✅ Accept optional [tsiId] (from screen).
  /// If not passed, fallback to SharedPrefs userId.
  Future<void> fetchTsiDisRetailerOrders({String? tsiId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();

      final effectiveTsiId = tsiId ?? userId;

      if (token == null || effectiveTsiId == null) {
        throw Exception("Missing token or TSI ID");
      }

      final response = await _dioClient.post(
        ApiEndpoints.tsiDisRet,
        data: {"tsm_id": effectiveTsiId},
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      _responseData = response.data;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
