import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:TrustTags_DMS/features/salesDashboard/provider/today_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/tsi_mapview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TsiActivity extends StatefulWidget {
  const TsiActivity({super.key});

  @override
  State<TsiActivity> createState() => _TsiActivityState();
}

class _TsiActivityState extends State<TsiActivity> {
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<TodayRouteScheduleProvider>();
      await provider.fetchTodayRouteSchedule();
      _calculateTotalDistance(provider);
    });
  }

  /// 📏 Calculate distance between two coordinates
  double _getDistanceFromLatLon(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Radius of Earth in KM
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  /// 🧮 Calculates total route distance from all completed users
  void _calculateTotalDistance(TodayRouteScheduleProvider provider) {
    final completedUsers = provider.schedule?.data?.completedUsers ?? [];
    if (completedUsers.length < 2) return;

    double total = 0.0;
    for (int i = 0; i < completedUsers.length - 1; i++) {
      final current = completedUsers[i];
      final next = completedUsers[i + 1];
      total += _getDistanceFromLatLon(
        current.latitude,
        current.longitude,
        next.latitude,
        next.longitude,
      );
    }

    setState(() {
      totalDistance = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<TodayRouteScheduleProvider>();
    final routeData = routeProvider.schedule?.data;

    final totalTasks = routeData?.total ?? 0;
    final pendingTasks = routeData?.pending ?? 0;
    final completedTasks = routeData?.complete ?? 0;
    final completedUsers = routeData?.completedUsers ?? [];

    return routeProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Activity Overview",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.trending_up, color: Colors.purple[600]),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Today's route progress overview",
              style: TextStyle(
                color: Colors.purple[700],
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 14),

            // 📊 Stats Row
            Row(
              children: [
                Expanded(child: _statCard("Tasks", "$totalTasks")),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard(
                    "Distance",
                    "${totalDistance.toStringAsFixed(2)} Km",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🧩 Pending / Completed Split
            Row(
              children: [
                Expanded(
                  child: _statCard("Pending", "$pendingTasks"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard("Completed", "$completedTasks"),
                ),
              ],
            ),

            // 🚀 Quick Actions
            const SizedBox(height: 10),
            _actionButton(Icons.map, "Map View", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TsiMapview()),
              );
            }),

            const SizedBox(height: 10),
            const Divider(),

            // 🕒 Recent Activities
            const Text(
              "Recent Activities",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            completedUsers.isEmpty
                ? const Text(
              "No activities found.",
              style: TextStyle(color: Colors.grey),
            )
                : Column(
              children: completedUsers
                  .map(
                    (user) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person,
                      color: Colors.purpleAccent),
                      title: Text(
                        "Visited: ${user.name}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      subtitle: Text(
                    user.type.toUpperCase(),
                    style:
                    const TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  .toList(),
            ),

            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------
  Widget _statCard(String title, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE1BEE7)], // purple gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.purple.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        )
      ],
    ),
    child: Column(
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
        ),
      );
}
