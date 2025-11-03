import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../model/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final DioClient dioClient;

  NotificationProvider({required this.dioClient});

  bool isLoading = false;
  String? errorMessage;
  List<AppNotification> notifications = [];

  Future<void> fetchNotifications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Get token
      final token = await SharedPrefsHelper.getAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception("No token found. Please login again.");
      }

      // 2. API request
      final response = await dioClient.get(
        ApiEndpoints.notifications,
        options: Options(
          headers: {'x-access-token': token},
        ),
      );

      // 3. Parse response
      final data = response.data;
      final notificationResponse = NotificationResponse.fromJson(data);

      notifications = notificationResponse.notifications;
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Error fetching notifications: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
