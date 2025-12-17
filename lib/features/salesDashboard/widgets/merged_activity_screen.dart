import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/merged_route_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_activity_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/mapview_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/tsi_mapview.dart';
class MergedActivityScreen extends StatefulWidget {
  const MergedActivityScreen({super.key});

  @override
  State<MergedActivityScreen> createState() => _MergedActivityScreenState();
}

class _MergedActivityScreenState extends State<MergedActivityScreen> {
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RouteActivityProvider>();

     final userId= await SharedPrefsHelper.getUserId();

      if (userId == null || userId.isEmpty) {
        debugPrint('❌ userId not found in SharedPreferences');
        return;
      }

      await provider.fetchRouteActivity(
        request: RouteActivityRequest(id: userId),
      );

      _calculateDistance();
    });
  }


  // ---------------- DISTANCE LOGIC ----------------
  void _calculateDistance() {
    final provider = context.read<RouteActivityProvider>();
    final completedUsers =
        provider.routeActivityResponse?.completedUsers ?? [];

    double total = 0.0;

    for (int i = 0; i < completedUsers.length - 1; i++) {
      final current = completedUsers[i];
      final next = completedUsers[i + 1];

      final lat1 = double.tryParse(current.latitude ?? '');
      final lon1 = double.tryParse(current.longitude ?? '');
      final lat2 = double.tryParse(next.latitude ?? '');
      final lon2 = double.tryParse(next.longitude ?? '');

      if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
        total += _getDistanceFromLatLon(lat1, lon1, lat2, lon2);
      }
    }

    setState(() => totalDistance = total);
  }

  double _getDistanceFromLatLon(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RouteActivityProvider>();

    final data = provider.routeActivityResponse;
    final completedUsers = data?.completedUsers ?? [];

    final totalTasks = data?.total ?? 0;
    final pendingTasks = data?.pending ?? 0;
    final completedTasks = data?.complete ?? 0;

    final isLoading = provider.isLoading;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AutoTranslateText(
                  "Activity Overview",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.trending_up, color: Colors.purple[600]),
              ],
            ),

            const SizedBox(height: 14),

            // ---------- STATS ----------
            Row(
              children: [
                Expanded(
                  child:
                  _statCard("Total Tasks", totalTasks.toString()),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard(
                    "Distance",
                    "${totalDistance.toStringAsFixed(1)} Km",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                    child:
                    _statCard("Pending", pendingTasks.toString())),
                const SizedBox(width: 8),
                Expanded(
                    child: _statCard(
                        "Completed", completedTasks.toString())),
              ],
            ),

            // ---------- ACTIONS ----------
            const SizedBox(height: 10),
            _actionButton(Icons.map, "Farmers Visit Route", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MapViewScreen()),
              );
            }),

            const SizedBox(height: 6),
            _actionButton(Icons.map_outlined, "Dis-Ret Route Map", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TsiMapview()),
              );
            }),

            const SizedBox(height: 10),
            const Divider(),

            // ---------- RECENT ----------
            const AutoTranslateText(
              "Recent Visits",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            if (completedUsers.isEmpty)
              const AutoTranslateText(
                "No activities found.",
                style: TextStyle(color: Colors.grey),
              )
            else
              ...completedUsers.take(5).map((user) {
                return _timelineItem(
                  title: user.name ?? 'Unknown',
                  subtitle: 'ROUTE VISIT',
                  icon: Icons.person,
                );
              }),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _statCard(String title, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        AutoTranslateText(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ],
    ),
  );

  Widget _actionButton(IconData icon, String title, {VoidCallback? onTap}) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Icon(icon, color: Colors.purpleAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(child: AutoTranslateText(title)),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      );

  Widget _timelineItem({
    required String title,
    required String subtitle,
    required IconData icon,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple[100],
              child: Icon(icon, size: 18, color: Colors.purple),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslateText(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  AutoTranslateText(
                    subtitle,
                    style:
                    const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
