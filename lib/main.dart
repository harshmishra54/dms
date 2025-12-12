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
import 'package:provider/provider.dart';

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
    EasyLocalization(
      supportedLocales: const [
        Locale('en'), // English
        Locale('hi'), // Hindi
        Locale('bn'), // Bengali
        Locale('te'), // Telugu
        Locale('mr'), // Marathi
        Locale('ta'), // Tamil
        Locale('or'), // Odia
        Locale('gu'), // Gujarati
        Locale('kn'), // Kannada
        Locale('ml'), // Malayalam
        Locale('pa'), // Punjabi
        Locale('as'), // Assamese
        Locale('sa'), // Sanskrit
        Locale('mai'), // Maithili
        Locale('kok'), // Konkani
        Locale('sat'), // Santali
        Locale('ks'), // Kashmiri
        Locale('ne'), // Nepali
        Locale('doi'), // Dogri
        Locale('mni'), // Manipuri (Meitei)
        Locale('brx'), // Bodo
      ],
      path: 'assets/translations', // Path to your translation JSONs
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLangCode),
      child: TrustTagsApp(
        dioClient: dioClient,
        profileRepository: profileRepository,
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),

        // Profile provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(repository: profileRepository),
        ),

        // Route-related providers
        ChangeNotifierProvider(
          create: (_) => RoutProvider(RoutRepository(DioClient())),
        ),
        ChangeNotifierProvider(
          create: (_) => RouteDetailsProvider(
            RouteUserListRepository(DioClient()),
          ),
        ),

        // Scan / dashboard / notifications
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => ChannelPerformanceProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(dioClient: dioClient),
        ),

        // Points / schemes
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => SchemeProvider()),
        // Leave Provider
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(
          create: (_) => DistributorProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TsiRetailerProvider()..fetchRetailers(),
          child: RetailersScreen(),
        ),
        ChangeNotifierProvider(create: (_) => MilestoneProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => InwardProvider()),
        ChangeNotifierProvider(create: (_) => CreditUpdateProvider()),
        ChangeNotifierProvider(create: (_) => CreditLimitProvider()),
        ChangeNotifierProvider(create: (_) => RouteDetailsProviders()),
        ChangeNotifierProvider(
          create: (_) => RouteUpdateStatusProvider(dioClient: DioClient()),
        ),
        ChangeNotifierProvider(create: (_) => RouteVisitProvider()),
        ChangeNotifierProvider(create: (_) => OrderProductProvider()),
        ChangeNotifierProvider(create: (_) => DistributorProviders()),
        ChangeNotifierProvider(
          create: (_) => AddOrderProvider(),
          child: PlaceNewOrderScreen(),
        ),
        ChangeNotifierProvider(create: (_) => OrderDetailsProvider()),
        ChangeNotifierProvider(create: (_)=> TsiDisRetailerProvider()),
        ChangeNotifierProvider(
          create: (_) => IptOrderListProvider(DioClient()),
          child: DistributorIpt(),
        ),
        ChangeNotifierProvider(create: (_)=> IptDistributorProvider()),
    ChangeNotifierProvider(
    create: (_) => ReceiveReturnClaimProvider(),
    child: DistributorReceivedReturnOrder(),
    ),
        ChangeNotifierProvider(create: (_)=> TsiOrderProvider()),
        ChangeNotifierProvider(create: (_) => TsiApproveOrderProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_)=> OrderListProvider()),
        ChangeNotifierProvider(create: (_)=> OrderUpdateProvider()),
        ChangeNotifierProvider(create: (_)=> PartiallyOrderUpdateProvider()),
        ChangeNotifierProxyProvider<OrderProductProvider, FocusProductProvider>(
          create: (_) => FocusProductProvider(OrderProductProvider()),
          update: (_, orderProductProvider, previous) =>
              FocusProductProvider(orderProductProvider),
        ),

        ChangeNotifierProvider(create: (_)=> TsiReturnOrderProvider()),
        ChangeNotifierProvider(create: (_)=> ReturnOrderDetailsProvider()),
        ChangeNotifierProvider(create: (_)=> TsiReturnApproveOrderProvider()),
        ChangeNotifierProvider(create: (_)=> ChildCodeScanProvider()),
        ChangeNotifierProvider(create: (_)=> DeleteScanProvider()),
        ChangeNotifierProvider(create: (_)=>InwardScanProvider()),
        ChangeNotifierProvider(create: (_)=> SubmitScanProvider()),
        ChangeNotifierProvider(create: (_)=> AttendanceProvider()),
        ChangeNotifierProvider(create: (_)=> AttendanceSubmitProvider()),
        ChangeNotifierProvider(create: (_)=> TerritoryProvider()),
        ChangeNotifierProvider(create: (_)=> TsiDistributorProvider()),
        ChangeNotifierProvider(create: (_)=> RouteAsmProvider()),
        ChangeNotifierProvider(create: (_)=> ZrtProvider()),
        ChangeNotifierProvider(create: (_)=> DistributorByIdProvider()),
        ChangeNotifierProvider(create: (_)=> TalukaProvider()),
        ChangeNotifierProvider(create: (_)=> RetailerProvider()),
        ChangeNotifierProvider(create: (_)=> RecieveReturnOrderListProvider()),
        ChangeNotifierProvider(create: (_)=> ReturnClaimOrderProvider()),
        ChangeNotifierProvider(create: (_)=> CancelUpdateOrderProvider()),
        ChangeNotifierProvider(create: (_)=> ReturnOrderProvider()),
        ChangeNotifierProvider(create: (_)=> AddReturnClaimProvider()),
        ChangeNotifierProvider(create: (_)=> OfferPointProvider()),
        ChangeNotifierProvider(create: (_)=> RouteMeetingProvider()),
        ChangeNotifierProvider(create: (_)=> SchemeRunningProvider()),
        ChangeNotifierProvider(create: (_)=> GetMyRewardProvider()),
        ChangeNotifierProvider(create: (_)=> RewardClaimHistoryProvider()),
        ChangeNotifierProvider(create: (_)=> RouteProvider()),
        ChangeNotifierProvider(create: (_)=> ThemeProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateOrderProvider()),
        ChangeNotifierProvider(create: (_)=> TsiListProvider()),
        ChangeNotifierProvider(create: (_)=> RejectTsiOrderProvider()),
        ChangeNotifierProvider(create: (_)=> DiscardAllItemsProvider()),
        ChangeNotifierProvider(create: (_)=> AcceptAllItemsProvider()),
        ChangeNotifierProvider(create: (_)=> RsmUpdateOrderProvider()),
        ChangeNotifierProvider(create: (_)=> ExpenseProvider()),
        ChangeNotifierProvider(create: (_)=> PartialAcceptOrderProvider()),
        ChangeNotifierProvider(create: (_)=> TodayRouteScheduleProvider()),
        ChangeNotifierProvider(create: (_)=> CreditLimitHistoryProvider()),
        ChangeNotifierProvider(create: (_)=> ProductLevelProvider()),
        ChangeNotifierProvider(create: (_)=> AllFocusNewProductStockProvider()),
        ChangeNotifierProvider(create: (_)=> PunchOutProvider()),
        ChangeNotifierProvider(create: (_)=> IptOrderUpdateProvider()),
        ChangeNotifierProvider(create: (_)=> IPTScanProvider()),
        ChangeNotifierProvider(create: (_)=> LogoutProvider()),
        ChangeNotifierProvider(create: (_)=> AddIPTOrderProvider()),
        ChangeNotifierProvider(create: (_)=> IptOrderDetailsProvider()),
        ChangeNotifierProvider(create: (_)=> RetailRsmProvider()),
        ChangeNotifierProvider(create: (_)=> DistributorRsmProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateRetailerRsmProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateDistributorProvider()),
        ChangeNotifierProvider(create: (_)=> ExpenseListProvider()),
        ChangeNotifierProvider(create: (_)=> LeaveCalendarProvider()),
        ChangeNotifierProvider(create: (_)=> MyLeaveProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateLeaveStatusProvider()),
        ChangeNotifierProvider(create: (_)=> FarmerQueryProvider()),
        ChangeNotifierProvider(create: (_)=> ListFarmerQueryProvider()),
        ChangeNotifierProvider(create: (_)=> FarmerDetailsProvider()),
        ChangeNotifierProvider(create: (_)=> ReorderProvider()),
        ChangeNotifierProvider(create: (_)=> CropProvider()),
        ChangeNotifierProvider(create: (_)=> AddFarmerProvider()),
        ChangeNotifierProvider(create: (_)=> FarmerFormDetailsProvider()),
        ChangeNotifierProvider(create: (_)=> RecommendedProductsProvider()),
        ChangeNotifierProvider(create: (_)=> DoctorHistoryProvider()),
        ChangeNotifierProvider(create: (_)=> CompleteReturnOrderProvider()),
        ChangeNotifierProvider(create: (_)=> RecommendationProvider()),
        ChangeNotifierProvider(create: (_)=> SmartRecommendationProvider()),
        ChangeNotifierProvider(create: (_)=> SmartProductRecommendationProvider()),
        ChangeNotifierProvider(create: (_)=> SchemeProductsProvider()),
        ChangeNotifierProvider(create: (_)=> AddProductPriceProvider()),
        ChangeNotifierProvider(create: (_)=> ProductRecommendationProvider()),
        ChangeNotifierProvider(create: (_)=> FarmerFunnelProvider()),
        ChangeNotifierProvider(create: (_)=> PurchaseDataProvider()),
        ChangeNotifierProvider(create: (_)=> GetMyFarmersProvider()),
        ChangeNotifierProvider(create: (_)=> AddBeatPlanDoctorProvider()),
        ChangeNotifierProvider(create: (_)=> GetBeatPlanDoctorProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateBeatPlanDoctorIndividualProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateBeatPlanDoctorProvider()),
        ChangeNotifierProvider(create: (_)=> GetActivityTimelineProvider()),
        ChangeNotifierProvider(create: (_)=> ProductCatalogueProvider()),
        ChangeNotifierProvider(create: (_)=> SpinnerRewardProvider()),
        ChangeNotifierProvider(create: (_)=> RetargetFarmerNewProvider()),
        ChangeNotifierProvider(create: (_)=> RetargetGapFarmerProvider()),
        ChangeNotifierProvider(create: (_)=> NotifyFarmer()),
        ChangeNotifierProvider(create: (_)=> AddFarmerPointsProvider()),
        ChangeNotifierProvider(create: (_)=> InviteEarnProvider()),
        ChangeNotifierProvider(create: (_)=> SpinnerHistoryProvider()),
        ChangeNotifierProvider(create: (_)=> AdvocacyProvider()),
        ChangeNotifierProvider(create: (_)=> RouteByPincodeProvider()),
        ChangeNotifierProvider(create: (_)=> RepeatPlanProvider()),
        ChangeNotifierProvider(create: (_)=> UpdateRecommendationProvider()),
        ChangeNotifierProvider(create: (_)=> FarmerConsiderationProvider()),
        ChangeNotifierProvider(create: (_)=> CfaStockProvider()),
        ChangeNotifierProvider(create: (_)=> AddPurchaseProvider()),
        ChangeNotifierProvider(create: (_)=> MyCategoryProvider()),
        ChangeNotifierProvider(create: (_)=> WeatherProvider()),
        ChangeNotifierProvider(create: (_)=> AgricultureProvider()),


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
