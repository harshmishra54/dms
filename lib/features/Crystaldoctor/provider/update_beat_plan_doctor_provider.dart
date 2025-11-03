import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/update_beat_plan_doctor_model.dart';

class UpdateBeatPlanDoctorProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateBeatPlanDoctorResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateBeatPlanDoctorResponse? get response => _response;

  /// ✅ Update Beat Plan Doctor Status
  Future<bool> updateBeatPlanDoctor({
    required String id,
    required String status,
    String? reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestBody = UpdateBeatPlanDoctorRequest(id: id, status: status,reason: reason);

      final response = await _dioClient.post(
        ApiEndpoints.updatedailyplan,
        data: requestBody.toJson(),
      );

      if (response.statusCode == 200) {
        _response = UpdateBeatPlanDoctorResponse.fromJson(response.data);
        if (kDebugMode) {
          debugPrint("✅ Beat Plan Doctor Updated: ${_response?.message}");
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Unexpected server response (${response.statusCode})";
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? "Something went wrong.";
      if (kDebugMode) debugPrint("🚨 Dio Error: $_errorMessage");
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) debugPrint("🚨 Exception: $_errorMessage");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _response = null;
    notifyListeners();
  }
}
