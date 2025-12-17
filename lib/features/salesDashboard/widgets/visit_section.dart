import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_activity_provider.dart';

class VisitSection extends StatelessWidget {
  const VisitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteActivityProvider>(
      builder: (context, provider, _) {
        final data = provider.routeActivityResponse;

        final total = data?.total ?? 0;
        final pending = data?.pending ?? 0;
        final complete = data?.complete ?? 0;

        // Debug log
        debugPrint(
          "📊 Route Activity → total: $total, pending: $pending, complete: $complete",
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoTranslateText(
              "Today Visits",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _VisitStat(
                  title: "Total",
                  count: total.toString(),
                  color: AppColors.topBarColor,
                ),
                _VisitStat(
                  title: "Pending",
                  count: pending.toString(),
                  color: Colors.orange,
                ),
                _VisitStat(
                  title: "Completed",
                  count: complete.toString(),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _VisitStat extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _VisitStat({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AutoTranslateText(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
