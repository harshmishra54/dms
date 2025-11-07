import 'dart:io';
import 'package:TrustTags_DMS/common/gradient_text.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/home/widgets/earned_points_section.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/notifications/presentation/notification_screen.dart';

import '../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../widgets/points_section.dart';
import '../widgets/stories_section.dart';
import '../widgets/schemes_banner.dart';
import '../widgets/discover_carousel.dart';
import '../../../common/widgets/custom_drawer.dart';

// TODO: Add this import with correct path
// import 'package:TrustTags_DMS/path/to/recommendation_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? selectedRole;
  final int? selectedRoleId;

  const DashboardScreen({
    super.key,
    this.selectedRole,
    this.selectedRoleId,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  // Floating button properties
  Offset _floatingPosition = const Offset(20, 400);
  bool _isDragging = false;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFreshData();
    });
  }

  Future<void> _fetchFreshData() async {
    final channelProvider =
    Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final dashboardProvider =
    Provider.of<DashboardProvider>(context, listen: false);

    // Fetch without trying to reset the state
    await channelProvider.fetchChannelPerformance();
    await dashboardProvider.fetchDashboardData();
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
    super.build(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
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
                                return CustomDrawerModal(
                                  onLogout: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LandingScreen(),
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
                          'TrustTags Sales',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          gradient: LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)], // Purple shades
                          ),
                        ),

                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationScreen(),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.notifications_none,
                            color: AppColors.topBarColor,
                          ),
                        ),
                        Image.asset(
                          'assets/images/trust_tags.png',
                          height: 35,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Main content
                Expanded(
                  child: Consumer<ChannelPerformanceProvider>(
                    builder: (context, provider, _) {
                      final channelData = provider.data?.data;

                      // Show cached data if available, otherwise loader
                      if (channelData == null) {
                        if (provider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (provider.errorMessage.isNotEmpty) {
                          return Center(child: AutoTranslateText(provider.errorMessage));
                        } else {
                          return const Center(child: AutoTranslateText('No data available'));
                        }
                      }

                      // Default values to avoid null errors
                      final points = (channelData.rewards?.points ?? 0).toDouble();
                      final schemeBanners = channelData.schemeBanners ?? [];
                      final scanCodes = channelData.counts ?? 0;

                      return RefreshIndicator(
                        onRefresh: _fetchFreshData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PointsSection(),
                              EarnedPointsSection(
                                earnedPoints: points,
                                scanCodes: scanCodes,
                              ),
                              const StoriesSection(),
                              if (schemeBanners.isNotEmpty) const DiscoverCarousel(),
                              if (schemeBanners.isNotEmpty) const SchemesBanner(),
                              const SizedBox(height: 20),
                            ],
                          ),
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
                    final bottomSafeArea = MediaQuery.of(context).padding.bottom + 70; // Safe area + button height
                    final maxY = screenHeight - bottomSafeArea - 70;

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
      ),
    );
  }
}