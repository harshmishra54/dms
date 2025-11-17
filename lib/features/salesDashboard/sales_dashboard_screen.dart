import 'dart:async';
import 'dart:io';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
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

  // Floating button properties
  Offset _floatingPosition = const Offset(20, 400);
  bool _isDragging = false;
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

    // Wait until first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoSlide();
    });
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 15), (timer) { // wait 15 sec between slides
      if (!_pageController.hasClients) return;

      final currentPage = _pageController.page?.round() ?? 0;
      final nextPage = currentPage == 0 ? 1 : 0;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(seconds: 1), // 1-second smooth animation
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

  void _fetchAllData() {
    final channelProvider = Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final todayRouteScheduleProvider = Provider.of<TodayRouteScheduleProvider>(context, listen: false);

    channelProvider.fetchChannelPerformance();
    dashboardProvider.fetchDashboardData();
    todayRouteScheduleProvider.fetchTodayRouteSchedule();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
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
                          'VNR Seeds',
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
                            Image.asset(
                              'assets/images/VNR_logo.jpeg',
                              height: 35,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 MAIN CONTENT (PageView + Stories + Schemes)
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
                            // 🟣 PAGE 1 — Dashboard + Stories + Schemes
                            SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔸 Tab Stats + Visits
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

                                  // 🔹 Stories Section
                                  const StoriesSection(),
                                  const SizedBox(height: 10),

                                  // 🔹 Discover Carousel
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

                                  const SizedBox(height: 10),

                                ],
                              ),
                            ),

                            // 🟣 PAGE 2 — Full Activity Overview
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TsiActivity(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 🔹 FLOATING AI ASSISTANT BUTTON
            Positioned(
              left: _floatingPosition.dx,
              top: _floatingPosition.dy,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() => _isDragging = true);
                },
                onPanUpdate: (details) {
                  setState(() {
                    final screenHeight = MediaQuery.of(context).size.height;
                    final bottomBarHeight = kBottomNavigationBarHeight + 20; // Bottom bar + padding
                    final maxY = screenHeight - bottomBarHeight - 70; // 70 is button height

                    _floatingPosition = Offset(
                      (_floatingPosition.dx + details.delta.dx).clamp(0.0, MediaQuery.of(context).size.width - 70),
                      (_floatingPosition.dy + details.delta.dy).clamp(0.0, maxY),
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() => _isDragging = false);
                  // Snap to nearest edge
                  final screenWidth = MediaQuery.of(context).size.width;
                  final shouldSnapLeft = _floatingPosition.dx < screenWidth / 2;

                  setState(() {
                    _floatingPosition = Offset(
                      shouldSnapLeft ? 20 : screenWidth - 90,
                      _floatingPosition.dy,
                    );
                  });
                },
                onTap: _openRecommendationScreen,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isDragging ? 1.1 : _pulseAnimation.value,
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
                              blurRadius: _isDragging ? 20 : 15,
                              spreadRadius: _isDragging ? 5 : 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: _isDragging ? 36 : 32,
                              ),
                            ),
                            // Small pulsing dot
                            if (!_isDragging)
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