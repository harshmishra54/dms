import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/send_feedback_user_id_model.dart';
import 'package:dio/dio.dart';

class FeedbackProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  FeedbackScheduleResponseModel? _feedbackResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FeedbackScheduleResponseModel? get feedbackResponse => _feedbackResponse;

  /// Call the /get-feedback API
  Future<void> sendFeedbackRequest(String userId, String message) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = SendFeedbackUserIdModel(
        userId: userId,
        message: message,
      );

      final token = await SharedPrefsHelper.getAccessToken();

      final Response response = await _dioClient.post(
        ApiEndpoints.sendfarmerId,
        data: model.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'x-access-token': token ?? "",
          },
        ),
      );

      _feedbackResponse =
          FeedbackScheduleResponseModel.fromJson(response.data);

    } catch (e) {
      _errorMessage = e.toString();
      _feedbackResponse = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
