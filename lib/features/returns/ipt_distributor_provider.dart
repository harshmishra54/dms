import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/distributor_data.dart';
import 'package:TrustTags_DMS/data/models/distributor_response.dart';
import 'package:TrustTags_DMS/data/models/recive_return_claim_post_data.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';



class IptDistributorProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<DistributorData> _distributors = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DistributorData> get distributors => _distributors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch distributor list from API
  Future<void> fetchDistributors(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();

      if (token == null || roleId == null) {
        throw Exception("Missing token or roleId");
      }

      final requestBody = ReceiveReturnClaimPostData(
        roleId: roleId.toString(),
        requestId: requestId,
      ).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.getCustomerList,
        data: requestBody,
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final parsed = DistributorResponse.fromJson(response.data);

      if (parsed.success == 1) {
        _distributors = parsed.data;
      } else {
        _errorMessage = parsed.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
