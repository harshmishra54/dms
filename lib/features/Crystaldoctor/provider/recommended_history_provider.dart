// doctor_history_provider.dart

import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/doctor_reco_history_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

class DoctorHistoryProvider with ChangeNotifier {
  final DioClient _dioClient;

  DoctorHistoryProvider({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<DoctorHistoryData> _history = [];
  List<DoctorHistoryData> get history => _history;

  /// Fetch doctor history by doctor id
  Future<void> fetchDoctorHistory(String doctorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null || token.isEmpty) {
        throw "Access token not found";
      }

      final response = await _dioClient.post(
        ApiEndpoints.gethistoryofrecommendation,
        data: {'id': doctorId},
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      if (response.data['success'] == 1) {
        final res = GetDoctorHistoryResponse.fromJson(response.data);
        _history = res.data;
      } else {
        _error = response.data['message'] ?? 'Failed to fetch doctor history';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear previous history
  void clearHistory() {
    _history = [];
    notifyListeners();
  }
}
