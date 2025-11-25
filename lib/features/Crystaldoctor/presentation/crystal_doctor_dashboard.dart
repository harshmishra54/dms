import 'dart:io';
import 'package:TrustTags_DMS/common/gradient_text.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_meeting.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/fill_details_form.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/funnel_stage_detail_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/register_farmer_by_crystal_doctor.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/beat_plan_doctor_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/chat_bot.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/crystal_doctor_custom_drawer.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/funnelactivity_carausel.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_advocacy_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_consideration_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/purchase_provider.dart';
import 'package:TrustTags_DMS/features/home/widgets/discover_carousel.dart';
import 'package:TrustTags_DMS/features/home/widgets/schemes_banner.dart';
import 'package:TrustTags_DMS/features/home/widgets/stories_section.dart';
import 'package:TrustTags_DMS/features/notifications/presentation/notification_screen.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/dashboard_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/attendance_popup.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/attendance_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class CrystalDoctorDashboard extends StatefulWidget {
  const CrystalDoctorDashboard({Key? key}) : super(key: key);

  @override
  State<CrystalDoctorDashboard> createState() => _CrystalDoctorDashboardState();
}

class _CrystalDoctorDashboardState extends State<CrystalDoctorDashboard>
    with RouteAware {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  int _expandedStage = -1;
  bool _isFirstLoad = true;



  @override
  void initState() {
    super.initState();
    _fetchData();
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


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route observer once
    final ModalRoute? modal = ModalRoute.of(context);
    if (modal is PageRoute) {
      routeObserver.subscribe(this, modal);
    }

    // Run attendance check only on first load
    if (_isFirstLoad) {
      _checkAttendanceAndShowPopup();
      _isFirstLoad = false;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }


  @override
  void didPopNext() {
    _fetchData();
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





  Future<bool> _onWillPop(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            const AppStatusBar(),
            _buildCustomAppBar(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _fetchData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(),
                      const SizedBox(height: 14),
                      FunnelActivityCarousel(funnelSection: _buildFarmerFunnelSection()),
                      const SizedBox(height: 10),
                      _buildFarmerManagementSection(),
                      const SizedBox(height: 10),
                      const StoriesSection(),
                      const DiscoverCarousel(),
                      const SchemesBanner(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Material(
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
                    return const CrystalDoctorCustomDrawer();
                  },
                );
              },
              child: const Icon(Icons.menu, color: Colors.black, size: 40),
            ),
            const GradientText(
              'Crystal Advisor',
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
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.topBarColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/crystal_logo.jpeg',
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade900,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 12),
                    AutoTranslateText(
                      'Welcome Back,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    AutoTranslateText(
                      'Farmer Advisor',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF8E24AA),
                      Color(0xFF6A1B9A),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 38,
                      color: Colors.white,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCE93D8), Color(0xFF9C27B0)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.stethoscope,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerManagementSection() {
    final items = [
      {
        'title': 'Farmer Consultation',
        'icon': Icons.person_add,
        'color': Colors.purple
      },
      {
        'title': 'Meet Up',
        'icon': Icons.people_outline,
        'color': Colors.deepPurple
      },
      {
        'title': 'Crystal GPT',
        'icon': Icons.psychology,
        'color': Colors.purple.shade800
      },
      {
        'title': 'Beat Plan',
        'icon': Icons.route,
        'color': Colors.deepPurple.shade700
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              child: _buildGridCard(
                item['title'] as String,
                item['icon'] as IconData,
                item['color'] as Color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFarmerFunnelSection() {
    return Consumer2<FarmerFunnelProvider, PurchaseDataProvider>(
      builder: (context, funnelProvider, purchaseProvider, child) {
        // Show loading only on initial load
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
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  const SizedBox(height: 12),
                  AutoTranslateText(
                    "Loading funnel data...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        // Calculate metrics (will return empty metrics if no data)
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
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AutoTranslateText(
                      'Sales Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              // Always show the funnel, even with zero metrics
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: GestureDetector(
                  onTapDown: (details) {
                    _handleFunnelTap(
                      details.localPosition,
                      size: const Size(320, 300),
                    );
                  },
                  child: CustomPaint(
                    size: const Size(320, 300),
                    painter: Funnel3DPainter(1.0, metrics),
                  ),
                ),
              ),
              // Optional: Show a subtle message if no farmers
              if (metrics.awareness == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AutoTranslateText(
                    'No farmer data available yet',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridCard(String title, IconData icon, Color color) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (title == "Farmer Consultation") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FillDetailsForm(),
                ),
              );
            } else if (title == "Meet Up") {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CrystalDoctorMeeting()),
              );
            } else if (title == "Crystal GPT") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecommendationScreen()),
              );
            } else if (title == "Beat Plan") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BeatPlanDoctorScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                AutoTranslateText(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Funnel Metrics Class
class FunnelMetrics {
  final int awareness;
  final int consideration;
  final int purchase;
  final int retention;
  final int advocacy;

  FunnelMetrics({
    required this.awareness,
    required this.consideration,
    required this.purchase,
    required this.retention,
    required this.advocacy,
  });

  factory FunnelMetrics.empty() {
    return FunnelMetrics(
      awareness: 0,
      consideration: 0,
      purchase: 0,
      retention: 0,
      advocacy: 0,
    );
  }

  String get conversionRate {
    if (awareness == 0) return '0%';
    return '${((advocacy / awareness) * 100).toStringAsFixed(1)}%';
  }

  String getPercentage(int stage) {
    if (awareness == 0) return '0%';

    int count;
    switch (stage) {
      case 0:
        count = awareness;
        break;
      case 1:
        count = consideration;
        break;
      case 2:
        count = purchase;
        break;
      case 3:
        count = retention;
        break;
      case 4:
        count = advocacy;
        break;
      default:
        count = 0;
    }

    return '${((count / awareness) * 100).toStringAsFixed(0)}%';
  }

  int getCount(int stage) {
    switch (stage) {
      case 0:
        return awareness;
      case 1:
        return consideration;
      case 2:
        return purchase;
      case 3:
        return retention;
      case 4:
        return advocacy;
      default:
        return 0;
    }
  }
}

// Funnel 3D Painter
class Funnel3DPainter extends CustomPainter {
  final double animationValue;
  final FunnelMetrics metrics;

  Funnel3DPainter(this.animationValue, this.metrics);

  final List<Color> baseColors = const [
    Color(0xFF7A00E0),
    Color(0xFF8E2DE2),
    Color(0xFFA259FF),
    Color(0xFFD16BA5),
    Color(0xFFF6C5EB),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final int sections = baseColors.length;
    final double sectionHeight = height / sections;

    _drawParticles(canvas, size);

    final stageNames = ['Awareness', 'Consideration', 'Purchase', 'Retention', 'Advocacy'];

    for (int i = 0; i < sections; i++) {
      if (animationValue < (i / sections)) continue;

      double sectionProgress =
      ((animationValue - (i / sections)) * sections).clamp(0.0, 1.0);

      double topY = i * sectionHeight;
      double bottomY = (i + 1) * sectionHeight;

      double topHalfWidth = (width / 2) * (1 - (i * 0.14));
      double bottomHalfWidth = (width / 2) * (1 - ((i + 1) * 0.14));

      _drawFunnelSection(
        canvas,
        width,
        topY,
        bottomY,
        topHalfWidth,
        bottomHalfWidth,
        baseColors[i],
        sectionProgress,
      );

      if (i == 0 || sectionProgress > 0.8) {
        _drawTopEllipse(canvas, width, topY, topHalfWidth, baseColors[i]);
      }

      if (i < sections - 1) {
        _drawSectionDivider(canvas, width, bottomY, bottomHalfWidth);
      }

      // ✅ ADD THIS: Draw labels for each section
      int count = metrics.getCount(i);
      int total = metrics.awareness;

      _drawLabels(
        canvas,
        width,
        topY,
        sectionHeight,
        topHalfWidth,
        bottomHalfWidth,
        stageNames[i],
        sectionProgress,
        count,
        total,
      );
    }

    if (animationValue > 0.8) {
      _drawBottomGlow(canvas, width, height);
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03);
    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawFunnelSection(
      Canvas canvas,
      double width,
      double topY,
      double bottomY,
      double topHalfWidth,
      double bottomHalfWidth,
      Color baseColor,
      double progress,
      ) {
    Path path = Path();
    path.moveTo(width / 2 - topHalfWidth, topY);

    path.lineTo(width / 2 + topHalfWidth, topY);

    path.cubicTo(
      width / 2 + topHalfWidth * 0.95,
      topY + (bottomY - topY) * 0.3,
      width / 2 + bottomHalfWidth * 1.05,
      topY + (bottomY - topY) * 0.7,
      width / 2 + bottomHalfWidth,
      bottomY,
    );

    path.lineTo(width / 2 - bottomHalfWidth, bottomY);

    path.cubicTo(
      width / 2 - bottomHalfWidth * 1.05,
      topY + (bottomY - topY) * 0.7,
      width / 2 - topHalfWidth * 0.95,
      topY + (bottomY - topY) * 0.3,
      width / 2 - topHalfWidth,
      topY,
    );

    path.close();

    Rect rect = Rect.fromLTWH(
      width / 2 - topHalfWidth,
      topY,
      topHalfWidth * 2,
      bottomY - topY,
    );

    Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          darken(baseColor, 0.2),
          baseColor,
          lighten(baseColor, 0.15),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, paint);

  }
  void _drawTopEllipse(
      Canvas canvas,
      double width,
      double topY,
      double halfWidth,
      Color baseColor,
      ) {
    final ellipseRect = Rect.fromCenter(
      center: Offset(width / 2, topY + 6),
      width: halfWidth * 2,
      height: 24,
    );

    Paint ellipsePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          lighten(baseColor, 0.3),
          baseColor,
          darken(baseColor, 0.2),
        ],
      ).createShader(ellipseRect);

    canvas.drawOval(ellipseRect, ellipsePaint);

    Paint rimPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      ellipseRect,
      math.pi,
      math.pi,
      false,
      rimPaint,
    );
  }

  void _drawLabels(
      Canvas canvas,
      double width,
      double topY,
      double sectionHeight,
      double topHalfWidth,
      double bottomHalfWidth,
      String topLabel,
      double progress,
      int count,
      int total,
      ) {
    // Stage Name
    TextSpan nameSpan = TextSpan(
      text: topLabel,
      style: TextStyle(
        color: Colors.white.withOpacity(0.95 * progress),
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );

    TextPainter nameTp = TextPainter(
      text: nameSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    nameTp.layout();

    // Count
    final percentage = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
    final countText = '$count Farmers ($percentage%)';

    TextSpan countSpan = TextSpan(
      text: countText,
      style: TextStyle(
        color: Colors.white.withOpacity(0.85 * progress),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.4),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
    );

    TextPainter countTp = TextPainter(
      text: countSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    countTp.layout();

    double centerY = topY + (sectionHeight / 2);
    double totalHeight = nameTp.height + countTp.height + 4;

    nameTp.paint(
      canvas,
      Offset(width / 2 - nameTp.width / 2, centerY - totalHeight / 2),
    );

    countTp.paint(
      canvas,
      Offset(width / 2 - countTp.width / 2, centerY - totalHeight / 2 + nameTp.height + 4),
    );
  }

  void _drawSectionDivider(
      Canvas canvas,
      double width,
      double y,
      double halfWidth,
      ) {
    Paint dividerPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(width / 2 - halfWidth, y);
    path.quadraticBezierTo(width / 2, y + 6, width / 2 + halfWidth, y);

    canvas.drawPath(path, dividerPaint);
  }

  void _drawBottomGlow(Canvas canvas, double width, double height) {
    Paint glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.bottomCenter,
        radius: 0.8,
        colors: [
          const Color(0xFF4DA6FF).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, height - 100, width, 100))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawRect(
      Rect.fromLTWH(0, height - 100, width, 100),
      glowPaint,
    );
  }

  Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  @override
  bool shouldRepaint(Funnel3DPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.metrics != metrics;
  }
}