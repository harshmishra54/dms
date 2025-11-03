import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/scan_child_code_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class ChildCodeScanProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  ScanInfoResponse? _scanResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ScanInfoResponse? get scanResponse => _scanResponse;

  /// 🔥 Scan API
  Future<void> scanCode(ScanInfoPostData requestData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      Response response = await _dioClient.post(
        ApiEndpoints.scanchildcode,
        data: requestData.toJson(),
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      _scanResponse = ScanInfoResponse.fromJson(response.data);
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
    _scanResponse = null;
    notifyListeners();
  }
}
