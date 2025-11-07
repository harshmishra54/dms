import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/invite_earn_model.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class InviteEarnProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  InviteEarnResponse? _inviteEarnResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  InviteEarnResponse? get inviteEarnResponse => _inviteEarnResponse;

  /// ✅ Generate referral code
  Future<void> generateReferralCode() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get user ID from SharedPreferences
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null || userId.isEmpty) {
        _errorMessage = "User ID not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final requestBody = {
        "id": userId, // matches API request
      };

      final response = await _dioClient.post(
        ApiEndpoints.inviteandearn,
        data: requestBody,
      );

      if (response.statusCode == 200 && response.data != null) {
        _inviteEarnResponse =
            InviteEarnResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        _errorMessage =
        "Failed to generate referral code. Status: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset response
  void reset() {
    _inviteEarnResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
