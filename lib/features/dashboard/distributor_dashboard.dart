import 'dart:io';
import 'package:TrustTags_DMS/common/gradient_text.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/home/presentation/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/common/widgets/distributor_custom_drawer.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

import 'package:TrustTags_DMS/features/dashboard/widgets/distributor_profile_card.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/points_units_card.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/dashboard_action_buttons.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';

import 'package:TrustTags_DMS/features/notifications/presentation/notification_screen.dart';
import 'package:TrustTags_DMS/features/home/widgets/discover_carousel.dart';
import 'package:TrustTags_DMS/features/home/widgets/schemes_banner.dart';
import 'package:TrustTags_DMS/features/home/widgets/stories_section.dart';

import 'inward_screen.dart';
class DistributorDashboard extends StatefulWidget {
  /// Optional param to tell which action button to highlight when opening dashboard
  final String? highlightAction;

  const DistributorDashboard({Key? key, this.highlightAction}) : super(key: key);

  @override
  State<DistributorDashboard> createState() => _DistributorDashboardState();
}

class _DistributorDashboardState extends State<DistributorDashboard> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fetch dashboard data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData();
      Provider.of<ChannelPerformanceProvider>(context, listen: false).fetchChannelPerformance();
    });
  }

  void _openInward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InwardScreen()),
    );
  }

  void _openReward(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanQRScreen()),
    );

    if (mounted) {
      Provider.of<ChannelPerformanceProvider>(context, listen: false).fetchChannelPerformance();
    }
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
                    // Drawer button
                    GestureDetector(
                      onTap: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Drawer',
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder: (context, _, __) {
                            return DistributorCustomDrawerModal(
                              onLogout: () {
                                Navigator.of(context).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => LandingScreen()),
                                      (route) => false,
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Icon(Icons.menu, color: Colors.black, size: 40),
                    ),

                    // Title
                    const GradientText(
                      'Crystal DMS',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                      ),
                    ),

                    // Notification + AI button (replaces logo)
                    Row(
                      children: [
                        // Notification
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

                        // Fixed AI Assistant Button
                        GestureDetector(
                          onTap: _openRecommendationScreen,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 40,
                                  height: 40,
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
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.psychology,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      // Small pulsing dot
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.greenAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.greenAccent.withOpacity(0.6),
                                                blurRadius: 6,
                                                spreadRadius: 1,
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

            // Main content
            Expanded(
              child: Consumer<DashboardProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return RefreshIndicator(
                    onRefresh: provider.fetchDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DistributorProfileCard(),
                          DashboardActionButtons(
                            onInwardTap: () => _openInward(context),
                            onScanTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ScanQRScreen()),
                              );

                              if (mounted) {
                                Provider.of<ChannelPerformanceProvider>(context, listen: false).fetchChannelPerformance();
                              }
                            },

                            onRewardTap: () => _openReward(context),
                            highlightAction: widget.highlightAction,
                          ),
                          PointsUnitsCard(),
                          StoriesSection(),
                          const DiscoverCarousel(),
                          const SizedBox(height: 10),
                          const SchemesBanner(),
                        ],
                      ),
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
