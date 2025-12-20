import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/complete_demo_model.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class CompleteDemoProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient(); // ✅ same as DemoHistoryProvider

  CompleteDemoResponse? _demoResponse;
  bool _isLoading = false;
  String? _error;

  CompleteDemoResponse? get demoResponse => _demoResponse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> completeDemo(String demoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken() ?? '';
      final requestBody = {'demo_id': demoId};

      final res = await _dioClient.post(
        ApiEndpoints.completeDemo,
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token,
          },
        ),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        _demoResponse = CompleteDemoResponse.fromJson(res.data);
      } else {
        _error = res.data['message'] ?? 'Something went wrong';
      }
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
