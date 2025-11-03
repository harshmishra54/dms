import 'package:TrustTags_DMS/features/points/providers/points_provider.dart';
import '../../../../common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointsSection extends StatefulWidget {
  const PointsSection({super.key});

  @override
  State<PointsSection> createState() => _PointsSectionState();
}

class _PointsSectionState extends State<PointsSection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<PointsProvider>(context, listen: false);
      provider.fetchScanHistory("1900-01-01", "2100-12-31");
    });
  }

  String maskCode(String? code) {
    if (code == null || code.isEmpty) return "-";
    if (code.length <= 4) return code;
    final start = code.substring(0, 2);
    final end = code.substring(code.length - 3);
    return "$start*****$end";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, _) {
        if (pointsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = pointsProvider.scanHistory;

        if (history.isEmpty) {
          return const Center(child: Text("No history found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];

            // Parse date
            final date = item.createdAt ?? '';
            final dateTime = DateTime.tryParse(date);
            final formattedDate = dateTime != null
                ? DateFormat('dd MMM yyyy').format(dateTime)
                : "-";

            // Points calculations
            final adjusted =
                double.tryParse(item.totalAdjusted ?? "0") ?? 0.0;
            final points = double.tryParse(item.points ?? "0") ?? 0.0;
            final remaining = (points - adjusted).clamp(0, double.infinity);

            // Product info
            final product = item.product;
            final productName = product?.name ?? "-";
            final imageUrl = product?.mainImage ?? "";

            // Scheme and code
            final schemeName = item.schemeName ?? "-";
            final uniqueCode = maskCode(item.uniqueCode);
            final level = item.level ?? "";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 4, left: 8, right: 8),
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (imageUrl.isNotEmpty)
                              ? Image.network(
                            imageUrl,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/images/trust_tags.png',
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Details column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(level),
                              Text(
                                uniqueCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(schemeName),
                            ],
                          ),
                        ),

                        // Points badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (adjusted > 0)
                                ? Colors.orange
                                : AppColors.topBarColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            adjusted > 0
                                ? "-$adjusted Adjusted"
                                : "$points Points",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Adjusted / Remaining section
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 12),
                  child: Text(
                    "$adjusted Adjusted    $remaining Remaining",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
