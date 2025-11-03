import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/get_beat_plan_doctor_model.dart';

class GetBeatPlanDoctorProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  GetBeatPlanDoctorResponse? _beatPlanDoctorResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GetBeatPlanDoctorResponse? get beatPlanDoctorResponse =>
      _beatPlanDoctorResponse;

  /// ✅ Fetch Beat Plan Doctor Data
  Future<void> fetchBeatPlanDoctor() async {
    _isLoading = true;
    _errorMessage = null;

    // 🔹 Clear old data before fetching (important!)
    _beatPlanDoctorResponse = null;
    notifyListeners();

    try {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId == null || userId.isEmpty) {
        throw Exception("User ID not found in SharedPrefs");
      }

      final token = await SharedPrefsHelper.getAccessToken();

      final request = GetBeatPlanDoctorRequest(userId: userId);

      final response = await DioClient().post(
        ApiEndpoints.showbeatplan,
        data: request.toJson(),
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-access-token": token ?? "",
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsedResponse =
        GetBeatPlanDoctorResponse.fromJson(response.data);

        if (parsedResponse.success == 1) {
          _beatPlanDoctorResponse = parsedResponse;
        } else {
          // 🔹 If API says no records, explicitly set empty list
          _beatPlanDoctorResponse = GetBeatPlanDoctorResponse(data: []);
          _errorMessage = null; // No error in this case
        }
      } else {
        _errorMessage =
        "Failed to fetch data. Status: ${response.statusCode}";
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Error in GetBeatPlanDoctorProvider: $e");
        print(stack);
      }
      _errorMessage = e.toString();
      _beatPlanDoctorResponse = GetBeatPlanDoctorResponse(data: []); // safe fallback
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Manual refresh (forces reload)
  Future<void> refreshBeatPlanDoctor() async {
    _beatPlanDoctorResponse = null;
    _errorMessage = null;
    await fetchBeatPlanDoctor();
  }
}
