import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/leave_list_request.dart';
import 'package:TrustTags_DMS/data/models/leave_management_response.dart';
import 'package:TrustTags_DMS/data/models/leave_request_data.dart';
import 'package:TrustTags_DMS/data/models/leave_request_response.dart';

class LeaveProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<LeaveManagementData> _leaveList = [];
  List<LeaveManagementData> get leaveList => _leaveList;

  String? _error;
  String? get error => _error;

  final DioClient _dioClient = DioClient();

  /// Fetch Leave List
  Future<void> fetchLeaveList(LeaveListRequest request, {required String token}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.client.post(
        ApiEndpoints.leaveList,
        data: request.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final leaveResponse = LeaveManagementResponse.fromJson(response.data);

      if (leaveResponse.success == 1) {
        _leaveList = leaveResponse.data;
        _error = null;
      } else {
        _leaveList = [];
        _error = leaveResponse.message;
      }
    } on DioError catch (dioError) {
      _leaveList = [];
      _error = _handleDioError(dioError);
    } catch (e) {
      _leaveList = [];
      _error = 'Unexpected error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Submit Leave Request
  Future<LeaveRequestResponse?> submitLeaveRequest(LeaveRequestData data, {required String token}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dioClient.client.post(
        ApiEndpoints.submitLeave,
        data: data.toJson(),
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final result = LeaveRequestResponse.fromJson(response.data);

      _error = result.success == 1 ? null : result.message;

      return result;
    } on DioError catch (dioError) {
      _error = _handleDioError(dioError);
      return null;
    } catch (e) {
      _error = 'Unexpected error occurred: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _handleDioError(DioError dioError) {
    switch (dioError.type) {
      case DioErrorType.cancel:
        return 'Request was cancelled';
      case DioErrorType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioErrorType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioErrorType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioErrorType.badResponse:
        if (dioError.response != null) {
          if (dioError.response!.statusCode == 500) {
            return 'Internal server error. Please try again later.';
          } else {
            return 'No Leave History';
          }
        } else {
          return 'Received invalid status code from server.';
        }
      case DioErrorType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}
