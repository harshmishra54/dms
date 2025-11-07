// providers/notify_farmer.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/notify_farmer_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class NotifyFarmer with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  NotificationResponse? _response;
  NotificationResponse? get response => _response;

  /// Send notification
  Future<void> sendNotification(NotificationRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.client.post(
        ApiEndpoints.notifyfarmer,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-access-token': token ?? '',
          },
        ),
      );

      _response = NotificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      _error = e.message ?? 'Something went wrong';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear previous response/error
  void clear() {
    _response = null;
    _error = null;
    notifyListeners();
  }
}
