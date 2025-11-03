import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/distributor_for_approval_model.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Request model for distributor RSM API
class GetDisRsmRequest {
  final String id;

  GetDisRsmRequest({required this.id});

  Map<String, dynamic> toJson() => {
    "id": id,
  };
}

class DistributorRsmProvider extends ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _loading = false;
  bool get loading => _loading;

  List<Distributor> _distributors = [];
  List<Distributor> get distributors => _distributors;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetch distributors for RSM with request body
  Future<void> fetchDistributors(String id) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ Get token from shared preferences
      final token = await SharedPrefsHelper.getAccessToken();

      // ✅ Prepare request body
      final requestBody = GetDisRsmRequest(id: id).toJson();

      final response = await _dioClient.post(
        ApiEndpoints.distributorforrsm,
        data: requestBody, // <-- request body here
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      if (response.statusCode == 200) {
        final apiResponse = GetDisRsmResponse.fromJson(response.data);
        _distributors = apiResponse.data;
      } else {
        _errorMessage =
        'Failed to fetch data. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) print('DistributorRsmProvider Error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Clear current data
  void clear() {
    _distributors = [];
    _errorMessage = null;
    notifyListeners();
  }
}
