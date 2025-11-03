import 'package:TrustTags_DMS/data/models/expense_list_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';

class ExpenseListProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  /// Fetch Expenses
  Future<void> fetchExpenses() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null) {
        _error = "User not logged in";
        _loading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.client.get(
        ApiEndpoints.expenseList,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      if (response.statusCode == 200) {
        final expenseResponse = ExpenseResponse.fromJson(response.data);
        if (expenseResponse.success == 1) {
          _expenses = expenseResponse.data;
        } else {
          _error = expenseResponse.message;
        }
      } else {
        _error = "Failed to fetch expenses: ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear expenses (optional)
  void clear() {
    _expenses = [];
    _error = null;
    notifyListeners();
  }
}
