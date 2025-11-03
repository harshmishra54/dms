import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_return_scan_code_models.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class ReturnOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddReturnScanCodeResponse? _scanResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddReturnScanCodeResponse? get scanResponse => _scanResponse;

  /// Add Return Claim Scan
  Future<void> addScanReturnClaim(String uniqueCode,String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception("No access token found. Please login again.");
      }

      final response = await _dioClient.post(
        ApiEndpoints.addreturnclaim,
        data: {
          "uniqueCode": uniqueCode,
          "id":id,
        },
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      _scanResponse = AddReturnScanCodeResponse.fromJson(response.data);
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
