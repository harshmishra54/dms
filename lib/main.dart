import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/common/provider/product_catalogue_provider.dart';
import 'package:TrustTags_DMS/common/provider/recommend_product_query_provider.dart';
import 'package:TrustTags_DMS/common/provider/recommend_provider.dart';
import 'package:TrustTags_DMS/common/provider/smart_recommendation_provider.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/core/network/offline_cache_service.dart';
import 'package:TrustTags_DMS/data/repositories/profile_repository.dart';
import 'package:TrustTags_DMS/data/repositories/rout_repository.dart';
import 'package:TrustTags_DMS/data/services/notification_service.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_farmer_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_farmer_points_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/crop_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_advocacy_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_consideration_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_form_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_query_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_activity_timeline_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_my_farmers_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_details_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_query_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/notify_farmer_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/product_recommendation_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/purchase_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/recommended_history_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/repeat_plan_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/retarget_farmer_new_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/retarget_gap_farmer_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/route_by_pincode_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/update_beat_plan_doctor_individual_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/update_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/RouteUpdateStatusProvider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/add_order_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/distributor_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/order_product_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/otp_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_details_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/rout_user_list_provider.dart';
import 'package:TrustTags_DMS/data/repositories/rout_user_list_repository.dart';
import 'package:TrustTags_DMS/features/authentication/provider/route_visit_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/scheme_wise_points_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/accept_all_items_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/cancel_order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_history_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_update_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/discard_all_items_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/focus_product_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/inward_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/meeting_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/milestone_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/my_category_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_list_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/order_update_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/partial_accept_all_items_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/partial_update_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/product_price_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reject_tsi_order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reorder_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reward_claim_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/scheme_products_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/tsi_approve_order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/tsi_order_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/distributor_new_order_screen.dart';
import 'package:TrustTags_DMS/features/farmer/provider/invite_earn_provider.dart';
import 'package:TrustTags_DMS/features/farmer/provider/recommended_products_provider.dart';
import 'package:TrustTags_DMS/features/farmer/provider/update_product_recommendation_provider.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/notifications/provider/notification_provider.dart';
import 'package:TrustTags_DMS/features/orders/presentation/retailers_screen.dart';
import 'package:TrustTags_DMS/features/orders/provider/distributor_provider.dart';
import 'package:TrustTags_DMS/features/orders/provider/order_details_provider.dart';
import 'package:TrustTags_DMS/features/orders/provider/retailer_provider.dart';
import 'package:TrustTags_DMS/features/orders/provider/tsi_dis_retailer_provider.dart';
import 'package:TrustTags_DMS/features/points/providers/points_provider.dart';
import 'package:TrustTags_DMS/features/points/providers/scheme_provider.dart';
import 'package:TrustTags_DMS/features/returns/distributor/distributor_IPT.dart';
import 'package:TrustTags_DMS/features/returns/distributor/distributor_received_return_order.dart';
import 'package:TrustTags_DMS/features/returns/ipt_distributor_provider.dart';
import 'package:TrustTags_DMS/features/returns/ipt_order_list_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/add_return_order_claim_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/approve_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/complete_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_add_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_order_details_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_order_update_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_scan_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/recieve_return_order_list_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/return_order_details_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/scan_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/tsi_approve_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/tsi_return_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/recieve_return_claim_provider.dart';
import 'package:TrustTags_DMS/features/rewards/provider/reward_claim_history_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/attendance_mark_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/attendance_status_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/punch_out_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/leave_calender_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/leave_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/my_leave_list_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/provider/update_leave_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/complete_demo_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/demo_history_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/provider/feedback_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/all_focus_new_product_stock_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/approve_distributor_registration_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/cfa_stock_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/complete_all_route_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_by_Id_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/distributor_for_approval_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/expense_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/expenselist_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/retailer_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/retailer_rsm_approval_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_activity_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_asm_provider.dart.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_meeting_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/rsm_update_order_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/taluka_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/today_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_distributor_registration_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_list_for_rsm_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_update_order_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/update_retailer_registration_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/zrt_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/add_purchase_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/child_code_delete_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/child_code_scan_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/inward_complete_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/inward_scan_details_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/product_level_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/scan_provider.dart';
import 'package:TrustTags_DMS/features/schemes/provider/scheme_running_provider.dart';
import 'package:TrustTags_DMS/features/spinner/provider/spinner_history_provider.dart';
import 'package:TrustTags_DMS/features/spinner/provider/spinner_reward_provider.dart';
import 'package:TrustTags_DMS/features/themes/theme_provider.dart';
import 'package:TrustTags_DMS/features/weather/provider/agriculture_provider.dart';
import 'package:TrustTags_DMS/features/weather/provider/weather_provider.dart';
import 'package:TrustTags_DMS/firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;


import 'features/splash/presentation/splash_screen.dart';

import 'features/authentication/presentation/otp_verification_screen.dart';
import 'features/authentication/provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2️⃣ Initialize Notification Service
  final notificationService = NotificationService();
  notificationService.setNavigatorKey(navigatorKey);
  await notificationService.init();

  // 3️⃣ Initialize Offline Cache (Isar)
  await OfflineCacheService.init();

  // 4️⃣ Create DioClient and repositories (single shared instance)
  final dioClient = DioClient();
  final profileRepository = ProfileRepository(dioClient: dioClient);

  // 5️⃣ Listen for connectivity changes globally
  final connectivity = Connectivity();
  connectivity.onConnectivityChanged.listen((status) async {
    if (status != ConnectivityResult.none) {
      debugPrint("📶 Internet Restored → Syncing pending offline requests...");
      await OfflineCacheService.syncPendingRequests(dioClient.client);
    } else {
      debugPrint("📴 No Internet Connection");
    }
  });

  // 6️⃣ Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  final prefs = await SharedPreferences.getInstance();
  final String savedLangCode = prefs.getString('app_lang') ?? 'en';

  // 7️⃣ Run app

  runApp(
    ProviderScope( // 👈 ADD THIS (Riverpod root)
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('bn'),
          Locale('te'),
          Locale('mr'),
          Locale('ta'),
          Locale('or'),
          Locale('gu'),
          Locale('kn'),
          Locale('ml'),
          Locale('pa'),
          Locale('as'),
          Locale('sa'),
          Locale('mai'),
          Locale('kok'),
          Locale('sat'),
          Locale('ks'),
          Locale('ne'),
          Locale('doi'),
          Locale('mni'),
          Locale('brx'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: Locale(savedLangCode),
        child: TrustTagsApp(
          dioClient: dioClient,
          profileRepository: profileRepository,
        ),
      ),
    ),
  );

}

class TrustTagsApp extends StatelessWidget {
  final ProfileRepository profileRepository;
  final DioClient dioClient;

  const TrustTagsApp({
    super.key,
    required this.profileRepository,
    required this.dioClient,
  });

  @override
  Widget build(BuildContext context) {
    return legacy.MultiProvider(
      providers: [
        legacy.ChangeNotifierProvider(create: (_) => AuthProvider()),
        legacy.ChangeNotifierProvider(create: (_) => OtpProvider()),

        // Profile provider
        legacy.ChangeNotifierProvider(
          create: (_) => ProfileProvider(repository: profileRepository),
        ),

        // Route-related providers
        legacy.ChangeNotifierProvider(
          create: (_) => RoutProvider(RoutRepository(DioClient())),
        ),
        legacy.ChangeNotifierProvider(
          create: (_) => RouteDetailsProvider(
            RouteUserListRepository(DioClient()),
          ),
        ),

        // Scan / dashboard / notifications
        legacy.ChangeNotifierProvider(create: (_) => ScanProvider()),
        legacy.ChangeNotifierProvider(create: (_) => ChannelPerformanceProvider()),
        legacy.ChangeNotifierProvider(create: (_) => DashboardProvider()),
        legacy.ChangeNotifierProvider(
          create: (_) => NotificationProvider(dioClient: dioClient),
        ),

        // Points / schemes
        legacy.ChangeNotifierProvider(create: (_) => PointsProvider()),
        legacy.ChangeNotifierProvider(create: (_) => SchemeProvider()),
        // Leave Provider
        legacy.ChangeNotifierProvider(create: (_) => LeaveProvider()),
        legacy.ChangeNotifierProvider(
          create: (_) => DistributorProvider(),
        ),
        legacy.ChangeNotifierProvider(
          create: (_) => TsiRetailerProvider()..fetchRetailers(),
          child: RetailersScreen(),
        ),
        legacy.ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        legacy.ChangeNotifierProvider(create: (_) => OrderProvider()),
        legacy.ChangeNotifierProvider(create: (_) => InwardProvider()),
        legacy.ChangeNotifierProvider(create: (_) => CreditUpdateProvider()),
        legacy.ChangeNotifierProvider(create: (_) => CreditLimitProvider()),
        legacy.ChangeNotifierProvider(create: (_) => RouteDetailsProviders()),
        legacy.ChangeNotifierProvider(
          create: (_) => RouteUpdateStatusProvider(dioClient: DioClient()),
        ),
        legacy.ChangeNotifierProvider(create: (_) => RouteVisitProvider()),
        legacy.ChangeNotifierProvider(create: (_) => OrderProductProvider()),
        legacy.ChangeNotifierProvider(create: (_) => DistributorProviders()),
        legacy.ChangeNotifierProvider(
          create: (_) => AddOrderProvider(),
          child: PlaceNewOrderScreen(),
        ),
        legacy.ChangeNotifierProvider(create: (_) => OrderDetailsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TsiDisRetailerProvider()),
        legacy.ChangeNotifierProvider(
          create: (_) => IptOrderListProvider(DioClient()),
          child: DistributorIpt(),
        ),
        legacy.ChangeNotifierProvider(create: (_)=> IptDistributorProvider()),
    legacy.ChangeNotifierProvider(
    create: (_) => ReceiveReturnClaimProvider(),
    child: DistributorReceivedReturnOrder(),
    ),
        legacy.ChangeNotifierProvider(create: (_)=> TsiOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_) => TsiApproveOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_) => MeetingProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> OrderListProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> OrderUpdateProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> PartiallyOrderUpdateProvider()),
        legacy.ChangeNotifierProxyProvider<OrderProductProvider, FocusProductProvider>(
          create: (_) => FocusProductProvider(OrderProductProvider()),
          update: (_, orderProductProvider, previous) =>
              FocusProductProvider(orderProductProvider),
        ),

        legacy.ChangeNotifierProvider(create: (_)=> TsiReturnOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ReturnOrderDetailsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TsiReturnApproveOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ChildCodeScanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DeleteScanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=>InwardScanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SubmitScanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AttendanceProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AttendanceSubmitProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TerritoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TsiDistributorProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RouteAsmProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ZrtProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DistributorByIdProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TalukaProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RetailerProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RecieveReturnOrderListProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ReturnClaimOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CancelUpdateOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ReturnOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddReturnClaimProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> OfferPointProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RouteMeetingProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SchemeRunningProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> GetMyRewardProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RewardClaimHistoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RouteProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ThemeProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TsiListProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RejectTsiOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DiscardAllItemsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AcceptAllItemsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RsmUpdateOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ExpenseProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> PartialAcceptOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> TodayRouteScheduleProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CreditLimitHistoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ProductLevelProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AllFocusNewProductStockProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> PunchOutProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> IptOrderUpdateProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> IPTScanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> LogoutProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddIPTOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> IptOrderDetailsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RetailRsmProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DistributorRsmProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateRetailerRsmProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateDistributorProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ExpenseListProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> LeaveCalendarProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> MyLeaveProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateLeaveStatusProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FarmerQueryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ListFarmerQueryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FarmerDetailsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ReorderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CropProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddFarmerProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FarmerFormDetailsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RecommendedProductsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DoctorHistoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CompleteReturnOrderProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RecommendationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SmartRecommendationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SmartProductRecommendationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SchemeProductsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddProductPriceProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ProductRecommendationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FarmerFunnelProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> PurchaseDataProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> GetMyFarmersProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddBeatPlanDoctorProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> GetBeatPlanDoctorProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateBeatPlanDoctorIndividualProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateBeatPlanDoctorProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> GetActivityTimelineProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> ProductCatalogueProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SpinnerRewardProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RetargetFarmerNewProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RetargetGapFarmerProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> NotifyFarmer()),
        legacy.ChangeNotifierProvider(create: (_)=> AddFarmerPointsProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> InviteEarnProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> SpinnerHistoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AdvocacyProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RouteByPincodeProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RepeatPlanProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> UpdateRecommendationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FarmerConsiderationProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CfaStockProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AddPurchaseProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> MyCategoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> WeatherProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> AgricultureProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> RouteActivityProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> DemoHistoryProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> CompleteDemoProvider()),
        legacy.ChangeNotifierProvider(create: (_)=> FeedbackProvider()),



      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'TrustTags-DMS',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              scaffoldBackgroundColor: Colors.white,
            ),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) {
                return const LandingScreen(
                );
              },
              '/otp': (context) {
                final args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
                return OtpVerificationScreen(
                  phoneNumber: args['phoneNumber'],
                  selectedRole: args['selectedRole'],
                  selectedRoleId: args['selectedRoleId'],
                  verificationKey: args['verificationKey'],
                  sessionId: args['sessionId'],
                  registrationId: args['registrationId'],
                );
              },
            },
          ),
        ),
      ),
    );
  }
}
