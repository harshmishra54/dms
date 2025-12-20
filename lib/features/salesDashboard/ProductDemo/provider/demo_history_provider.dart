import 'package:TrustTags_DMS/data/models/demo_history_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';


class DemoHistoryProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  /// STATE
  bool _isLoading = false;
  String? _errorMessage;
  DemoHistoryResponse? _response;

  /// GETTERS
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DemoHistoryResponse? get response => _response;

  List<DemoHistoryItem> get demoHistoryList =>
      _response?.data ?? [];

  /// RESET
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }

  /// ===============================
  /// FETCH DEMO HISTORY (POST)
  /// ===============================
  Future<void> fetchDemoHistory({
    required DemoHistoryRequest request,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _dioClient.post(
        ApiEndpoints.getdemohistory,
        data: request.toJson(),
      );

      if (res.data != null && res.data['success'] == 1) {
        _response = DemoHistoryResponse.fromJson(res.data);
      } else {
        _errorMessage = res.data?['message'] ?? 'Something went wrong';
      }
    } catch (e) {
      debugPrint("❌ DemoHistoryProvider error: $e");
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
