// scheme_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
 // 👈 renamed model
import 'package:TrustTags_DMS/data/models/scheme_running_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SchemeRunningProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<RewardData> _rewards = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RewardData> get rewards => _rewards;

  /// Fetch My Rewards
  Future<void> fetchMyRewards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();

      if (token == null || roleId == null) {
        throw Exception("Missing token or role id");
      }

      /// ✅ Send `role_id` in request body
      final response = await _dioClient.post(
        ApiEndpoints.schemesrunning, // 👈 API endpoint same hai
        data: {
          "role_id": roleId,
        },
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rewardResponse = RewardResponse.fromJson(response.data);

        if (rewardResponse.success) {
          _rewards = rewardResponse.data;
        } else {
          _rewards = [];
          _errorMessage = "No rewards found";
        }
      } else {
        _errorMessage = "Failed to fetch rewards";
      }
    } catch (e) {
      _errorMessage = e.toString();
      _rewards = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRewards() {
    _rewards = [];
    notifyListeners();
  }
}
