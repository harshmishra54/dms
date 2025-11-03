import 'package:TrustTags_DMS/data/models/expense_req_res_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
// <-- request/response models

class ExpenseProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  ExpenseAddResponse? _expenseResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ExpenseAddResponse? get expenseResponse => _expenseResponse;

  /// ✅ Add Expense API
  Future<void> addExpense(ExpenseAddRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final response = await _dioClient.post(
        ApiEndpoints.expenseAdd,
        data: request.toJson(),
        options: Options(
          headers: {
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200) {
        _expenseResponse = ExpenseAddResponse.fromJson(response.data);
      } else {
        _errorMessage = "Unexpected error: ${response.statusCode}";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset state (optional)
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _expenseResponse = null;
    notifyListeners();
  }
}
