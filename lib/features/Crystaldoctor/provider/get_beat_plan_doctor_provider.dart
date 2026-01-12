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

  // ✅ SINGLE SOURCE OF TRUTH
  String? _activeUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  GetBeatPlanDoctorResponse? get beatPlanDoctorResponse =>
      _beatPlanDoctorResponse;

  /// ✅ Fetch Beat Plan Doctor Data
  Future<void> fetchBeatPlanDoctor({String? userId}) async {
    _isLoading = true;
    _errorMessage = null;
    _beatPlanDoctorResponse = null;

    // 🔥 LOCK USER ID (ONLY ON FIRST VALID INPUT)
    if (userId != null && userId.isNotEmpty) {
      _activeUserId = userId;
    }

    notifyListeners();

    try {
      // ❌ NO GUESSING ANYMORE
      final finalUserId =
          _activeUserId ?? await SharedPrefsHelper.getUserId();

      if (finalUserId == null || finalUserId.isEmpty) {
        throw Exception("User ID not available");
      }

      final token = await SharedPrefsHelper.getAccessToken();

      final request = GetBeatPlanDoctorRequest(
        userId: finalUserId,
      );

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
          _beatPlanDoctorResponse =
              GetBeatPlanDoctorResponse(data: []);
        }
      } else {
        _errorMessage =
        "Failed to fetch data. Status: ${response.statusCode}";
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ GetBeatPlanDoctorProvider error: $e");
        print(stack);
      }
      _errorMessage = e.toString();
      _beatPlanDoctorResponse =
          GetBeatPlanDoctorResponse(data: []);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Manual refresh (USES SAME USER ALWAYS)
  Future<void> refreshBeatPlanDoctor() async {
    _beatPlanDoctorResponse = null;
    _errorMessage = null;
    await fetchBeatPlanDoctor();
  }

  /// ✅ Reset when screen is disposed / role changes
  void clear() {
    _activeUserId = null;
    _beatPlanDoctorResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

