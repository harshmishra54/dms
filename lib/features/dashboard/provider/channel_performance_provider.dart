import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/utils/shared_prefs_helper.dart';
import '../../../../data/models/channel_performance_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';

class ChannelPerformanceProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  ChannelPerformanceResponse? _channelPerformanceResponse;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  ChannelPerformanceResponse? get data => _channelPerformanceResponse;

  Future<void> fetchChannelPerformance() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        _errorMessage = "Session expired. Please login again.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final dio = DioClient().client;

      final response = await dio.get(
        ApiEndpoints.channelPerformance,
        options: Options(
          headers: {
            "x-access-token": token, // header from your Kotlin code
          },
        ),
      );

      if (response.statusCode == 200) {
        _channelPerformanceResponse =
            ChannelPerformanceResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = "Error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

}
