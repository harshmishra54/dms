import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
import 'package:TrustTags_DMS/data/models/tsi_distributor_data.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';


class DistributorProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  List<TsiDistributorData> _distributors = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TsiDistributorData> get distributors => _distributors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDistributors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');  // ✅ Correct key
      final tsmId = prefs.getString('user_id');       // ✅ Correct key


      if (token == null || tsmId == null) {
        _errorMessage = 'Missing token or TSM ID';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.distributorOrders,
        data: {
          "tsm_id": tsmId,
        },
        options: Options(
          headers: {
            'x-access-token': token,
          },
        ),
      );

      final data = response.data;
      if (data['success'].toString() == "1") {
        _distributors = (data['data'] as List)
            .map((json) => TsiDistributorData.fromJson(json))
            .toList();
      } else {
        _errorMessage = data['message'] ?? 'Failed to fetch distributors';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
