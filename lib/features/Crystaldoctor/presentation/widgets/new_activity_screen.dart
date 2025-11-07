import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_activity_timeline_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/mapview_screen.dart';

class NewActivityScreen extends StatefulWidget {
  const NewActivityScreen({super.key});

  @override
  State<NewActivityScreen> createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<GetActivityTimelineProvider>();
      await provider.fetchActivityTimeline();
      _calculateDistance(provider.activityTimelineResponse?.data ?? []);
    });
  }

  void _calculateDistance(List<dynamic> activities) {
    double total = 0.0;
    for (int i = 0; i < activities.length - 1; i++) {
      final current = activities[i];
      final next = activities[i + 1];

      final lat1 = double.tryParse(current.latitude.toString());
      final lon1 = double.tryParse(current.longitude.toString());
      final lat2 = double.tryParse(next.latitude.toString());
      final lon2 = double.tryParse(next.longitude.toString());

      if (lat1 != null && lon1 != null && lat2 != null && lon2 != null) {
        total += _getDistanceFromLatLon(lat1, lon1, lat2, lon2);
      }
    }
    setState(() => totalDistance = total);
  }

  double _getDistanceFromLatLon(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<GetActivityTimelineProvider>();
    final activities = activityProvider.activityTimelineResponse?.data ?? [];
    final totalCount = activityProvider.activityTimelineResponse?.count ?? activities.length;

    return activityProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))
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
                const AutoTranslateText(
                  "Activity Overview",
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.trending_up, color: Colors.purple[600]),
              ],
            ),
            const SizedBox(height: 8),
            AutoTranslateText(
              "Keep it up! You're making great progress.",
              style:
              TextStyle(color: Colors.purple[700], fontSize: 13),
            ),

            const SizedBox(height: 14),

            // 📊 Stats Row
            Row(
              children: [
                Expanded(child: _statCard("Tasks", "$totalCount")),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard(
                    "Distance",
                    "${totalDistance.toStringAsFixed(1)} Km",
                  ),
                ),
              ],
            ),



            // 🚀 Quick Actions
            const SizedBox(height: 6),
            _actionButton(Icons.map, "Map View", onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MapViewScreen()),
              );
            }),

            const SizedBox(height: 8),
            const Divider(),

            const AutoTranslateText(
              "Recent Activities",
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),

            if (activities.isEmpty)
              const AutoTranslateText(
                "No activities found.",
                style: TextStyle(color: Colors.grey),
              ),
            ...activities.take(3).map((activity) {
              return _timelineItem(
                title: activity.name ?? "Unnamed Farmer",
                icon: Icons.person,
              );
            }),

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
        AutoTranslateText(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        AutoTranslateText(
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
                child: AutoTranslateText(
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

  Widget _timelineItem({
    required String title,
    required IconData icon,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple[100],
              child: Icon(icon, color: Colors.purple, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AutoTranslateText(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
}
