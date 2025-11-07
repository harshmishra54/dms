import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/send_otp_request.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();

  bool isLoading = false;
  String? errorMessage;

  Future<Map<String, dynamic>?> sendOtp({
    required String phone,
    required BuildContext context,
    required String selectedRole,
    required int selectedRoleId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final request = SendOtpRequest(
        phone: phone,
        userType: selectedRoleId,
      );

      final response = await _authRepo.sendOtp(request);

      final sessionId = response.sessionData?.sessionId;
      final registrationId = response.sessionData?.registrationId;

      if (response.success == 1 && sessionId != null && registrationId != null) {
        return {
          'verificationKey': response.data,
          'sessionId': sessionId,
          'registrationId': registrationId,
        };
      } else {
        errorMessage = response.message ?? 'Missing session or registration ID.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText(errorMessage!)),
        );
        return null;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(errorMessage!)),
      );
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}