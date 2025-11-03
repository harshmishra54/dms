import 'package:TrustTags_DMS/data/models/update_leave_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class UpdateLeaveStatusProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateLeaveStatusResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateLeaveStatusResponse? get response => _response;

  /// Update leave status API call
  Future<void> updateLeaveStatus(UpdateLeaveStatusRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    _response = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final res = await _dioClient.post(
        ApiEndpoints.updateleavestatus,
        data: request.toJson(),
        options: Options(headers: {
          'x-access-token': token ?? '',
        }),
      );

      _response = UpdateLeaveStatusResponse.fromJson(res.data);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
