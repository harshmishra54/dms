import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/tsi_return_order_models.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';


class TsiReturnOrderProvider with ChangeNotifier {
  final DioClient _dioClient = DioClient();

  bool _isLoading = false;
  String? _errorMessage;
  List<TsiReturnOrderItem> _orders = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TsiReturnOrderItem> get orders => _orders;

  /// Fetch TSI return orders
  Future<void> fetchTsiReturnOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await SharedPrefsHelper.getAccessToken();
      final roleId = await SharedPrefsHelper.getRoleId();
      final requestId = await SharedPrefsHelper.getUserId();

      if (token == null || roleId == null || requestId == null) {
        _errorMessage = "Missing authentication details";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _dioClient.post(
        ApiEndpoints.tsiorderreturn, // ✅ /pwa/list-return-claim
        data: {
          "role_id": roleId.toString(),
          "request_id": requestId.toString(),
        },
        options: Options(
          headers: {"x-access-token": token},
        ),
      );

      final tsiReturnOrderList = TsiReturnOrderList.fromJson(response.data);

      if (tsiReturnOrderList.success == 1) {
        _orders = tsiReturnOrderList.data;
      } else {
        _errorMessage = tsiReturnOrderList.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear data
  void clearOrders() {
    _orders = [];
    notifyListeners();
  }
}
