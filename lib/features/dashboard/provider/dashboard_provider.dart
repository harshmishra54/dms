import 'package:TrustTags_DMS/data/models/dashboard_response.dart';
import 'package:TrustTags_DMS/data/services/api_service.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  DashboardData? data;

  Future<void> fetchDashboardData() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      final api = ApiService();
      final response = await api.fetchDashboardData();
      data = response?.data;
    } catch (e) {
      errorMessage = e.toString();

      // Check if it's a 401 error
      if (e is DioException && e.response?.statusCode == 401) {
        _handleUnauthorized();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _handleUnauthorized() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Please login again."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SharedPrefsHelper.clearAll();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (route) => false,
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}