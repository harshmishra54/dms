import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/features/scan/models/scan_post_data.dart';
import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ScanProvider with ChangeNotifier {
  bool isLoading = false;

  /// Helper to extract clean error message
  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return e.message ?? 'Unknown Dio error';
    }
    return e.toString();
  }

  /// POST pwa/validateUID
  Future<ScanResponse> validateUID(String token, ScanPostData request) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient().post(
        ApiEndpoints.validateUID,
        data: request.toJson(),
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      return ScanResponse.fromJson(response.data);
    } catch (e) {
      final errorMsg = _extractErrorMessage(e);
      debugPrint("❌ validateUID failed: $errorMsg");
      return ScanResponse(success: 0, message: errorMsg, data: null);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
