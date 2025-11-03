import 'package:TrustTags_DMS/data/models/ipt_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart'; // adjust path as needed
import '../../core/utils/shared_prefs_helper.dart';
 // Your request/response models
import '../../core/network/api_endpoints.dart';

class IptOrderListProvider with ChangeNotifier {
  final DioClient _dioClient;

  IptOrderListProvider(this._dioClient);

  bool _isLoading = false;
  String? _errorMessage;
  List<IptOrderData> _iptOrders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<IptOrderData> get iptOrders => _iptOrders;

  Future<void> fetchIptOrderList({required bool isReceived, required String requestId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken() ?? '';

      final requestBody = IptOrderListRequest(
        isReceived: isReceived,
        requestId: requestId,
      );

      final response = await _dioClient.post(
        ApiEndpoints.iptOrderList, // Define this in your api_endpoints.dart like '/pwa/ipt-order-list'
        data: requestBody.toJson(),
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      if (response.statusCode == 200) {
        final data = IptOrderListResponse.fromJson(response.data);
        if (data.success == 1) {
          _iptOrders = data.data;
        } else {
          _errorMessage = 'Failed to load IPT orders';
          _iptOrders = [];
        }
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _iptOrders = [];
      }
    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
      _iptOrders = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
