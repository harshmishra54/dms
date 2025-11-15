// file: logout_provider.dart
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/logout_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class LogoutProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  LogoutResponse? _logoutResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LogoutResponse? get logoutResponse => _logoutResponse;

  final DioClient _dioClient = DioClient();

  /// ✅ Manually control loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// ✅ Logout API call
  Future<void> logout() async {
    setLoading(true);
    _errorMessage = null;

    try {
      // Get role_id and user id from SharedPrefs
      final roleId = await SharedPrefsHelper.getRoleId();
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAccessToken();

      if (roleId == null || userId == null || token == null) {
        _errorMessage = "Invalid user data";
        setLoading(false);
        return;
      }

      final request = LogoutRequest(
        roleId: roleId.toString(),
        id: userId,
      );

      final response = await _dioClient.client.post(
        ApiEndpoints.logout,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        _logoutResponse = LogoutResponse.fromJson(response.data);

        // ✅ Clear all stored preferences on logout
        await SharedPrefsHelper.clearAll();

        // ✅ (Extra safety) Clear cached provider data if any
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          notifyListeners(); // force refresh any UI still referencing old data
        });

      } else {
        _errorMessage = "Failed to logout. Please try again.";
      }
    } on DioException catch (e) {
      _errorMessage = e.message ?? "Something went wrong";
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setLoading(false);
    }
  }
}
