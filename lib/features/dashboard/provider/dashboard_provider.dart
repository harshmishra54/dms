import 'package:TrustTags_DMS/data/models/dashboard_response.dart';
import 'package:TrustTags_DMS/data/services/api_service.dart';
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

      final api = ApiService(); // create an instance
      final response = await api.fetchDashboardData(); // non-static method
      data = response?.data;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
