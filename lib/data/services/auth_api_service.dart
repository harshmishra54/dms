// lib/data/services/auth_api_service.dart

import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';
import '../../core/network/dio_client.dart';

class AuthApiService {
  final DioClient _dioClient = DioClient();

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.sendOtp,
        data: request.toJson(),
      );

      return SendOtpResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }
}
