import 'package:TrustTags_DMS/data/models/advisor_route_plan_model.dart';
import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class AddBeatPlanDoctorProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  AddBeatPlanDoctorResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AddBeatPlanDoctorResponse? get response => _response;

  /// 🚀 Add Beat Plan Doctor Entry
  Future<void> addBeatPlanDoctor({
    required List<String> farmerIds,
    required String date,
    required String routName,
    String? userId, // 👈 ADD THIS
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Prefer passed userId, fallback to SharedPrefs
      final finalUserId =
          userId ?? await SharedPrefsHelper.getUserId();

      if (finalUserId == null || finalUserId.isEmpty) {
        throw Exception("User ID not found. Please login again.");
      }

      final request = AddBeatPlanDoctorRequest(
        userId: finalUserId, // ✅ USE CORRECT USER
        farmerIds: farmerIds, // ❌ untouched
        date: date,
        routName: routName,
      );

      final response = await _dioClient.post(
        ApiEndpoints.addadvisorRoute,
        data: request.toJson(),
      );

      if (response.data["offline"] == true) {
        _response = AddBeatPlanDoctorResponse(
          success: 1,
          message:
          response.data["message"] ?? "Saved offline. Will sync later.",
          data: null,
        );
      } else {
        _response = AddBeatPlanDoctorResponse.fromJson(response.data);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}

