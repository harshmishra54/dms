import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/verify_otp_request.dart';
import '../../../data/models/verify_otp_response.dart';

class OtpProvider extends ChangeNotifier {
  final ApiService apiService = ApiService(); // Use shared ApiService with internal DioClient

  bool isLoading = false;
  String? errorMessage;

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🧾 Debug prints to verify what you're sending
      print("🚀 Sending verify OTP request: ${request.toJson()}");
      print("🔑 verification_key being sent: ${request.verificationKey}");

      final response = await apiService.verifyOtp(request);

      if (response != null && response.success == 1) {
        errorMessage = null;
        return response;
      } else {
        errorMessage = response?.message ?? "Verification failed";
        return null;
      }
    } catch (e) {
      errorMessage = "Something went wrong";
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}
