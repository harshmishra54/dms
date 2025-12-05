import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard.dart';
import 'package:TrustTags_DMS/features/home/presentation/history_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/scan_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/schemes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/provider/channel_performance_provider.dart';
import '../../dashboard/provider/dashboard_provider.dart';


class FarmerDashboardHomenavigation extends StatefulWidget {
  final int initialIndex;

  const FarmerDashboardHomenavigation({Key? key, this.initialIndex = 0})
      : super(key: key);

  @override
  State<FarmerDashboardHomenavigation> createState() =>
      _FarmerDashboardHomenavigationState();
}

class _FarmerDashboardHomenavigationState
    extends State<FarmerDashboardHomenavigation> {
  late int _selectedIndex;
  int? roleId;
  final DioClient _dioClient = DioClient(); // create instance

  Future<void> _loadRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roleId = prefs.getInt('role_id');
    });
  }

  final List<Widget> _screens = const [
    FarmerDashboard(),
    HistoryScreen(),
    ScanQRScreen(),
    SchemesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _loadRoleId();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);


    if (index == 0) {
    _refreshDashboard();
    }


  }

  /// ✅ Refresh Dashboard safely with context-aware 401 handling
  void _refreshDashboard() async {
    final channelProvider =
    Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final dashboardProvider =
    Provider.of<DashboardProvider>(context, listen: false);


    try {
    // Wrap in try-catch to catch Dio 401
    await channelProvider.fetchChannelPerformanceWithContext(context);
    await dashboardProvider.fetchDashboardDataWithContext(context);
    } catch (e) {
    debugPrint("Error refreshing dashboard: $e");
    }


  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          roleId: roleId,
        ),
      ),
    );
  }
}

// ===========================================
// ✅ Extension: Add context-aware fetch methods
// ===========================================
extension ContextAwareFetch on ChannelPerformanceProvider {
  Future<void> fetchChannelPerformanceWithContext(BuildContext context) async {
    try {
      await fetchChannelPerformance();
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        _showUnauthorizedDialog(context);
        rethrow;
      }
    }
  }

  void _showUnauthorizedDialog(BuildContext context) {
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
              await SharedPreferences.getInstance()
                  .then((prefs) => prefs.clear());
              if (context.mounted) {
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
}

extension DashboardFetchContext on DashboardProvider {
  Future<void> fetchDashboardDataWithContext(BuildContext context) async {
    try {
      await fetchDashboardData();
    } catch (e) {
      if (e.toString().contains("Unauthorized")) {
        _showUnauthorizedDialog(context);
        rethrow;
      }
    }
  }

  void _showUnauthorizedDialog(BuildContext context) {
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
              await SharedPreferences.getInstance()
                  .then((prefs) => prefs.clear());
              if (context.mounted) {
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
}
