import 'dart:convert';
import 'package:TrustTags_DMS/data/models/get_tsi_list_for_rsm_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/core/network/api_endpoints.dart';
 // <-- Your request/response model

class TsiListProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<TsiUser> _tsiUsers = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TsiUser> get tsiUsers => _tsiUsers;

  /// Fetch TSI List for RSM
  Future<void> fetchTsiList(String rsmId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();

      final request = GetTsiListRequest(id: rsmId);

      final response = await _dioClient.post(
        ApiEndpoints.getTsilistforrsm,
        data: jsonEncode(request.toJson()),
        options: Options(
          headers: {
            'x-access-token': token ?? '',
          },
        ),
      );

      final parsed = GetTsiListResponse.fromJson(response.data);

      if (parsed.success == 1) {
        _tsiUsers = parsed.data;
      } else {
        _errorMessage = "Failed to load TSI List";
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _tsiUsers = [];
    _errorMessage = null;
    notifyListeners();
  }
}
