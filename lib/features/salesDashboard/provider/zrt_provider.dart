import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../data/models/zrt_model.dart'; // <-- Your request/response models

class ZrtProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _error;
  ZrtResponse? _zrtResponse;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ZrtResponse? get zrtResponse => _zrtResponse;

  /// Call API
  Future<void> fetchZRT() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final userId = await SharedPrefsHelper.getUserId();

      if (token == null || userId == null) {
        throw Exception("User not logged in or missing credentials");
      }

      final request = ZrtRequest(id: userId);

      final response = await _dioClient.post(
        ApiEndpoints.zrtfinder,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      _zrtResponse = ZrtResponse.fromJson(response.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
