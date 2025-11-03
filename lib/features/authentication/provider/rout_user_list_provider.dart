import 'package:flutter/foundation.dart';
import 'package:TrustTags_DMS/data/models/rout_visit_user_list_response.dart';
import 'package:TrustTags_DMS/data/repositories/rout_user_list_repository.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class RouteDetailsProvider with ChangeNotifier {
  final RouteUserListRepository repository;

  bool isLoading = false;
  RoutVisitUserListResponse? data;

  RouteDetailsProvider(this.repository);

  Future<void> fetchRouteVisitUserList(String tsiRouteVisitId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Get token from SharedPreferences
      final token = await SharedPrefsHelper.getAccessToken();

      if (token == null) {
        debugPrint("Token not found. Please login again.");
        isLoading = false;
        notifyListeners();
        return;
      }

      // Pass both routeId and token
      data = await repository.getRouteVisitUserList(tsiRouteVisitId, token);
    } catch (e) {
      debugPrint('Error fetching route visit user list: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
