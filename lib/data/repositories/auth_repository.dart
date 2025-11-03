import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../models/send_otp_request.dart';
import '../models/send_otp_response.dart';

class AuthRepository {
  final Dio _dio = DioClient().client;

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOtp,
        data: request.toJson(),
      );

      print('Response data runtimeType: ${response.data.runtimeType}');
      print('Raw response data: ${response.data}');

      final data = response.data; // Already a Map<String, dynamic>

      return SendOtpResponse.fromJson(data);

    } on DioException catch (e) {
      throw Exception(e.response?.data.toString() ?? 'Failed to send OTP');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }


}
