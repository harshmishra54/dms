import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/update_beat_plan_doctor_individual_model.dart';

class UpdateBeatPlanDoctorIndividualProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  UpdateBeatPlanDoctorIndividualResponse? _response;
  UpdateBeatPlanDoctorIndividualResponse? get response => _response;

  /// ✅ Update individual Beat Plan Doctor (farmer status)
  Future<void> updateBeatPlanDoctorIndividual({
    required String id,
    required String status,
    required String fid,
  }) async {
    _isLoading = true;
    _message = null;
    notifyListeners();

    try {
      // Create request body
      final request =
      UpdateBeatPlanDoctorIndividualRequest(id: id, status: status, fid: fid);

      // Get token from SharedPrefs
      final token = await SharedPrefsHelper.getAccessToken();

      // POST API call
      final response = await _dioClient.client.post(
        ApiEndpoints.updateindividual,
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        _response = UpdateBeatPlanDoctorIndividualResponse.fromJson(response.data);
        _message = _response?.message ?? 'Update successful';
      } else {
        _message = 'Unexpected server response';
      }
    } catch (e) {
      debugPrint("🚨 Error in updateBeatPlanDoctorIndividual: $e");
      _message = "Something went wrong. Please try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear previous data (optional for screen refresh)
  void reset() {
    _response = null;
    _message = null;
    _isLoading = false;
    notifyListeners();
  }
}
