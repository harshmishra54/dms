// reward_claim_history_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/user_reward_history_model.dart';

class RewardClaimHistoryProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  UserRewardHistoryResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserRewardHistoryResponse? get response => _response;

  /// Fetch Reward Claim History
  Future<void> fetchRewardClaimHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();

      if (token == null || userId == null) {
        _errorMessage = "User not logged in.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final request = UserRewardHistoryRequest(userId: userId);

      final response = await _dioClient.post(
        ApiEndpoints.claimrewardsHistory,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token,
          },
        ),
      );

      _response = UserRewardHistoryResponse.fromJson(response.data);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
