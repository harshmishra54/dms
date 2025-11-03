// reorder_provider.dart
import 'package:TrustTags_DMS/data/models/reorder_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:dio/dio.dart';

enum ReorderStatus { initial, loading, success, error }

class ReorderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  ReorderStatus _status = ReorderStatus.initial;
  ReorderStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ReorderResponse? _reorderResponse;
  ReorderResponse? get reorderResponse => _reorderResponse;

  Future<void> createReorder(ReorderRequest request) async {
    _status = ReorderStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      // Make API call
      final response = await _dioClient.post(
        ApiEndpoints.reordersameproduct,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      _reorderResponse = ReorderResponse.fromJson(response.data);
      _status = ReorderStatus.success;
    } on DioException catch (e) {
      _errorMessage = e.message;
      _status = ReorderStatus.error;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ReorderStatus.error;
    }

    notifyListeners();
  }

  void reset() {
    _status = ReorderStatus.initial;
    _errorMessage = null;
    _reorderResponse = null;
    notifyListeners();
  }
}
