import 'dart:async';
import 'dart:io';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';
import 'package:TrustTags_DMS/data/models/merged_route_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/funnel_stage_detail_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_advocacy_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_consideration_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/purchase_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_activity_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/merged_activity_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/tsi_activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/common/gradient_text.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

import 'package:TrustTags_DMS/features/salesDashboard/Attendance/attendance_popup.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/attendance_status_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/today_rout_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/home/widgets/stories_section.dart';
import 'package:TrustTags_DMS/features/home/widgets/discover_carousel.dart';
import 'package:TrustTags_DMS/features/home/widgets/schemes_banner.dart';
import 'package:TrustTags_DMS/features/notifications/presentation/notification_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/Sales_custom_Drawer.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/bottom_bar.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/tab_stat_section.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/visit_section.dart';

class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  bool _isFirstLoad = true;
  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;


  // Pulse animation for AI icon
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start auto slide after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide();
    });
  }
  void _fetchData() async {
    final createdBy = await SharedPrefsHelper.getUserId(); // ✅ await the future

    context.read<DashboardProvider>().fetchDashboardData();
    context.read<ChannelPerformanceProvider>().fetchChannelPerformance();
    context.read<FarmerFunnelProvider>().fetchFarmerFunnel();
    context.read<AdvocacyProvider>().fetchAdvocacy();
    context.read<PurchaseDataProvider>().fetchPurchaseData();

    if (createdBy != null) {
      context.read<FarmerConsiderationProvider>().fetchConsideration(
        createdBy: createdBy,
      );
    }
  }
  void _handleFunnelTap(Offset localPosition, {required Size size}) {
    final double y = localPosition.dy;
    const int sections = 5; // 5 funnel stages
    final double sectionHeight = size.height / sections;

    // Determine tapped stage index
    final int tappedSection = (y ~/ sectionHeight).clamp(0, sections - 1);

    // Stage names
    const stageNames = ['Awareness', 'Consideration', 'Purchase', 'Retention', 'Advocacy'];

    // Navigate to FunnelStageDetailScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FunnelStageDetailScreen(
          stageIndex: tappedSection,
          stageName: stageNames[tappedSection],
        ),
      ),
    );
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_pageController.hasClients) return;

      final currentPage = _pageController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % 3; // 🔥 3 pages now

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad || ModalRoute.of(context)?.isCurrent == true) {
      _fetchAllData();
      _checkAttendanceAndShowPopup();
      _isFirstLoad = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && ModalRoute.of(context)?.isCurrent == true) {
      _fetchAllData();
    }
  }

  void _fetchAllData() async{
    final createdBy = await SharedPrefsHelper.getUserId(); // ✅ await the future

    context.read<DashboardProvider>().fetchDashboardData();
    context.read<ChannelPerformanceProvider>().fetchChannelPerformance();
    context.read<FarmerFunnelProvider>().fetchFarmerFunnel();
    context.read<AdvocacyProvider>().fetchAdvocacy();
    context.read<PurchaseDataProvider>().fetchPurchaseData();

    if (createdBy != null) {
      context.read<FarmerConsiderationProvider>().fetchConsideration(
        createdBy: createdBy,
      );
    }
    final channelProvider = Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final todayRouteScheduleProvider = Provider.of<RouteActivityProvider>(context, listen: false);

    channelProvider.fetchChannelPerformance();
    dashboardProvider.fetchDashboardData();
    if (createdBy != null) {
      todayRouteScheduleProvider.fetchRouteActivity(
        request: RouteActivityRequest(
          id: createdBy,
        ),
      );
    }
  }

  void _checkAttendanceAndShowPopup() async {
    final attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    await attendanceProvider.checkAttendanceStatus();

    if (attendanceProvider.attendanceStatus != null &&
        attendanceProvider.attendanceStatus!.data == false) {
      _showAttendancePopup();
    }
  }

  void _showAttendancePopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AttendancePopup(),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText("Exit App"),
        content: const AutoTranslateText("Do you want to exit the app?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const AutoTranslateText("No"),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else {
                exit(0);
              }
            },
            child: const AutoTranslateText("Yes"),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  void _openRecommendationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationScreen()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }
  FunnelMetrics _calculateMetrics(
      FarmerFunnelResponse? funnelData,
      PurchaseDataProvider purchaseProvider,
      ) {
    if (funnelData?.data == null || funnelData!.data!.isEmpty) {
      return FunnelMetrics.empty();
    }

    final farmers = funnelData.data!;

    // Awareness = total unique farmers
    final awareness = farmers.length;

    // Consideration = farmers in FarmerConsiderationProvider
    final considerationProvider = context.read<FarmerConsiderationProvider>();
    final consideration = considerationProvider.farmers.length;

    // Purchase = total purchase farmers
    final purchase = purchaseProvider.purchaseList.length;

    // Retention = repeat purchase farmers
    final retention = purchaseProvider.repeatPurchaseList.length;

    // Advocacy = API count from provider
    final advocacy = context.read<AdvocacyProvider>().advocacyCount;

    return FunnelMetrics(
      awareness: awareness,
      consideration: consideration,
      purchase: purchase,
      retention: retention,
      advocacy: advocacy,
    );
  }

  Widget _buildFarmerFunnelSection() {
    return Consumer2<FarmerFunnelProvider, PurchaseDataProvider>(
      builder: (context, funnelProvider, purchaseProvider, child) {
        if (funnelProvider.isLoading && funnelProvider.farmerFunnel == null) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          );
        }

        final metrics = _calculateMetrics(
          funnelProvider.farmerFunnel,
          purchaseProvider,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AutoTranslateText(
                  'Sales Analytics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              /// 🔥 Responsive Funnel Area
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;

                  // Adaptive height logic
                  final funnelHeight = (screenHeight * 0.32)
                      .clamp(220.0, 360.0); // min & max safe limits

                  final funnelWidth =
                  constraints.maxWidth.clamp(260.0, 360.0);

                  final funnelSize = Size(funnelWidth, funnelHeight);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: GestureDetector(
                      onTapDown: (details) {
                        _handleFunnelTap(
                          details.localPosition,
                          size: funnelSize,
                        );
                      },
                      child: CustomPaint(
                        size: funnelSize,
                        painter: Funnel3DPainter(1.0, metrics),
                      ),
                    ),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const AppStatusBar(),

            // 🔹 TOP BAR
            Material(
              elevation: 3,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Drawer',
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder: (context, _, __) {
                            return const SalesCustomDrawer();
                          },
                        );
                      },
                      child: const Icon(Icons.menu, color: Colors.black, size: 40),
                    ),
                    const GradientText(
                      'Crystal Sales',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationScreen()),
                            );
                          },
                          child: const Icon(Icons.notifications_none, color: AppColors.topBarColor),
                        ),
                        const SizedBox(width: 12),

                        // ✅ Pulsing AI icon fixed here
                        GestureDetector(
                          onTap: _openRecommendationScreen,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0).withOpacity(0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(Icons.psychology, color: Colors.white, size: 32),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.greenAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.greenAccent.withOpacity(0.6),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 MAIN CONTENT
            Expanded(
              child: Consumer2<ChannelPerformanceProvider, DashboardProvider>(
                builder: (context, channelProvider, dashboardProvider, _) {
                  final hasError = channelProvider.errorMessage.isNotEmpty ||
                      dashboardProvider.errorMessage.isNotEmpty;

                  if ((channelProvider.data == null || dashboardProvider.data == null) && !hasError) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AutoTranslateText(
                            "Failed to load data",
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchAllData,
                            child: const AutoTranslateText("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  final channelData = channelProvider.data?.data;

                  return RefreshIndicator(
                    onRefresh: () async {
                      _fetchAllData();
                    },
                    child: PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // PAGE 1 — Dashboard Overview
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.grey.shade100,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const TabStatSection(),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black12, blurRadius: 6)
                                  ],
                                ),
                                child: const VisitSection(),
                              ),
                              const SizedBox(height: 8),
                              const StoriesSection(),
                              const SizedBox(height: 10),
                              if (channelData?.schemeBanners != null &&
                                  channelData!.schemeBanners!.isNotEmpty)
                                const DiscoverCarousel()
                              else
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.center,
                                  child: const AutoTranslateText(
                                    "No schemes to discover",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // PAGE 2 — FARMER FUNNEL (NEW)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: _buildFarmerFunnelSection(),
                          ),
                        ),

                        // PAGE 3 — TSI ACTIVITY
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: MergedActivityScreen(),
                        ),
                      ],

                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // 🔹 BOTTOM BAR
        bottomNavigationBar: const Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: BottomBar(),
        ),
      ),
    );
  }
}
