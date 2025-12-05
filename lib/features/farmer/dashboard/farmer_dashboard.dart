import 'dart:io';
import 'package:TrustTags_DMS/common/gradient_text.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_custom_drawer.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_profile_card.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/points_units_card.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/notifications/presentation/notification_screen.dart';
import 'package:TrustTags_DMS/features/home/widgets/discover_carousel.dart';
import 'package:TrustTags_DMS/features/home/widgets/schemes_banner.dart';
import 'package:TrustTags_DMS/features/home/widgets/stories_section.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ✅ Fetch data and handle 401
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataWithErrorHandling();
      Provider.of<ChannelPerformanceProvider>(context, listen: false)
          .fetchChannelPerformance();
    });
  }

  // ✅ Wrapper method to handle 401 errors
  Future<void> _fetchDataWithErrorHandling() async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    await provider.fetchDashboardData();

    // Check if 401 error occurred
    if (mounted && provider.errorMessage.isNotEmpty) {
      if (provider.errorMessage.contains('401') ||
          provider.errorMessage.toLowerCase().contains('unauthorized')) {
        _showSessionExpiredDialog();
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Session Expired"),
        content: const Text("Please login again."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await SharedPrefsHelper.clearAll();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                      (route) => false,
                );
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _openRecommendationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationScreen()),
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

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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

            // Top bar
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
                            return FarmerCustomDrawer(
                              onLogout: () {
                                Navigator.of(context).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LandingScreen(),
                                  ),
                                      (route) => false,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.menu, color: Colors.black, size: 40),
                    ),
                    const GradientText(
                      'Crystal Farmer',
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

                        // ✅ Pulsing AI icon
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

            // Main Scrollable Content
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            color: Colors.grey,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: AutoTranslateText(
                              "Unable to load dashboard data",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: AutoTranslateText(
                              "Please check your connection and try again",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              _fetchDataWithErrorHandling(); // ✅ Use wrapper method
                            },
                            icon: const Icon(Icons.refresh),
                            label: const AutoTranslateText("Retry"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _fetchDataWithErrorHandling, // ✅ Use wrapper method
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                FarmerDashboardProfileCard(),
                                PointsUnitsCard(),
                                SizedBox(height: 10),
                                StoriesSection(),
                                DiscoverCarousel(),
                                SizedBox(height: 10),
                                SchemesBanner(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}