import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/inward_preview_model.dart';

class InwardProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _error;
  InwardPreview? _inwardPreview;

  bool get isLoading => _isLoading;
  String? get error => _error;
  InwardPreview? get inwardPreview => _inwardPreview;

  /// ✅ Fetch API
  Future<void> fetchInwardDetails(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.get(
        ApiEndpoints.retailerInwardPreview,
        queryParameters: {'orderId': orderId},
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      _inwardPreview = InwardPreview.fromJson(response.data);
    } on DioException catch (e) {
      _error = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message'] ?? 'Failed to fetch inward details'
          : 'Failed to fetch inward details';
    } catch (e) {
      _error = 'Unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Clear state when leaving ScanDetailsScreen
  void clearInwardPreview() {
    _inwardPreview = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
