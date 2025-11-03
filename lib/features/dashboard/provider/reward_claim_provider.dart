import 'package:TrustTags_DMS/data/models/reward_claim_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs_helper.dart';


class GetMyRewardProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  GetMyRewardResponse? _rewardResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GetMyRewardResponse? get rewardResponse => _rewardResponse;

  /// Fetch My Reward API
  Future<void> fetchMyReward(String rewardId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();
      final userId = await SharedPrefsHelper.getUserId();

      if (token == null || roleId == null || userId == null) {
        throw Exception("User not logged in or missing credentials.");
      }

      final request = GetMyRewardRequest(
        rewardId: rewardId,
        roleId: roleId.toString(),
        userId: userId,
      );

      final response = await _dioClient.post(
        ApiEndpoints.claimrewards,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      if (response.statusCode == 200) {
        _rewardResponse = GetMyRewardResponse.fromJson(response.data);
      } else {
        _errorMessage = "Failed with status code: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
