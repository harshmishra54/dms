// lib/features/dashboard/provider/milestone_provider.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../data/models/milestone_response.dart';

class MilestoneProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<MilestoneData> _milestones = [];
  List<MilestoneData> get milestones => _milestones;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchMilestones() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId(); // ✅ fetch roleId

      if (token == null || token.isEmpty) {
        _errorMessage = "Access token not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (roleId == null) {
        _errorMessage = "Role ID not found.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // ✅ prepare request body
      final requestBody = MilestoneRequest(roleId: roleId).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.milestone,
        data: requestBody, // ✅ send roleId in body
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final parsed = MilestoneResponse.fromJson(response.data);
        if (parsed.success == 1) {
          _milestones = parsed.data;
        } else {
          _errorMessage = parsed.message;
        }
      } else {
        _errorMessage = 'Failed to load milestones';
      }
    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
