import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_history_screen.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/recieved_order_list.dart';
import 'package:TrustTags_DMS/features/orders/presentation/received_order_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  late GlobalKey<NavigatorState> navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  Future<void> init() async {
    await _requestPermission();

    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: null, // optional callback for iOS < 10
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings, // add iOS settings here
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClickFromPayload(response.payload);
      },
    );

    // FCM listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClickFromMessage);

    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClickFromMessage(initialMessage);
    }
  }

  Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined notification permission');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null && data.isNotEmpty) {
      String? imageUrl = data['imageUrl']; // optional image in FCM payload

      AndroidNotificationDetails androidDetails;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        androidDetails = AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          channelDescription: 'Channel for general notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigPictureStyleInformation(
            FilePathAndroidBitmap(imageUrl), // local path of image
            contentTitle: notification.title,
            summaryText: notification.body,
          ),
        );
      } else {
        androidDetails = AndroidNotificationDetails(
          'default_channel',
          'General Notifications',
          channelDescription: 'Channel for general notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
            summaryText: '', // optional summary
          ),
        );
      }

      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails),
        payload: data['orderId'],
      );
    }
  }



  void _handleNotificationClickFromMessage(RemoteMessage message) async {
    final data = message.data;

    String? orderId = data['orderId'];
    String? distributorId = data['distributorId'];
    String? notificationRoleIdStr = data['roleId']; // From notification
    int? notificationRoleId =
    notificationRoleIdStr != null ? int.tryParse(notificationRoleIdStr) : null;

    // Fetch current user's roleId from shared prefs to decide navigation
    int currentUserRoleId = await SharedPrefsHelper.getRoleId() ?? 0;

    _handleNotificationClick(orderId, distributorId, notificationRoleId, currentUserRoleId);
  }

  void _handleNotificationClickFromPayload(String? payload) async {
    // If you store distributorId & roleId in payload JSON, parse it here
    // Example: {"orderId":"123","distributorId":"456","roleId":"18"}
    if (payload == null) return;

    // Parse JSON payload (you need to send full data in payload if using local notification)
    final Map<String, dynamic> data = Map<String, dynamic>.from(
        payload.isNotEmpty ? Uri.decodeFull(payload) as Map : {});
    String? orderId = data['orderId'];
    String? distributorId = data['distributorId'];
    int? notificationRoleId =
    data['roleId'] != null ? int.tryParse(data['roleId']) : null;

    int currentUserRoleId = await SharedPrefsHelper.getRoleId() ?? 0;

    _handleNotificationClick(orderId, distributorId, notificationRoleId, currentUserRoleId);
  }

  void _handleNotificationClick(String? orderId, String? distributorId,
      int? notificationRoleId, int currentUserRoleId) {
    if (orderId == null || navigatorKey.currentState == null) return;

    // Navigation decision based on current logged-in user's roleId
    if (currentUserRoleId == 1) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => RecievedOrderList()),
      );
    } else if (currentUserRoleId == 18 || currentUserRoleId == 19) {
      // Pass distributorId and roleId from notification
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ReceivedOrderListScreen(
            distributorId: distributorId ?? '',
            roleId: notificationRoleId ?? 0,
          ),
        ),
      );
    } else if (currentUserRoleId == 3) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => const DistributorHistoryScreen(initialTabIndex: 1), // Open TSI tab
        ),
      );
    }

  }

  Future<String?> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
    return token;
  }

  Future<void> deleteToken() async {
    await FirebaseMessaging.instance.deleteToken();
    print("FCM token deleted from device");
  }
}
