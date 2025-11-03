import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/my_leave_model.dart'; // <- Your request/response models

class MyLeaveProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<MyLeave> _leaves = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MyLeave> get leaves => _leaves;

  /// Fetch My Leaves
  Future<void> fetchMyLeaves() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = await SharedPrefsHelper.getUserId();
      final token = await SharedPrefsHelper.getAccessToken();

      if (userId == null || token == null) {
        _errorMessage = "User not logged in";
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Request body
      final requestBody = MyLeaveRequest(id: userId).toJson();

      final response = await _dioClient.client.post(
        ApiEndpoints.getallmyleave,
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final parsed = MyLeaveResponse.fromJson(response.data);

      if (parsed.success == 1) {
        _leaves = parsed.data;
      } else {
        _errorMessage = parsed.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear all leaves (optional helper)
  void clear() {
    _leaves = [];
    notifyListeners();
  }
}
