import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';

class PointsUnitsCard extends StatefulWidget {
  const PointsUnitsCard({super.key});

  @override
  State<PointsUnitsCard> createState() => _PointsUnitsCardState();
}

class _PointsUnitsCardState extends State<PointsUnitsCard>
    with TickerProviderStateMixin {
  late AnimationController _borderController;

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
          padding: const EdgeInsets.all(2), // thin border thickness
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.purpleAccent,
                Colors.deepPurple,
                Colors.purpleAccent,
              ],
              stops: [
                (_borderController.value * 0.5).clamp(0.0, 1.0),
                (_borderController.value * 0.7).clamp(0.0, 1.0),
                (_borderController.value * 0.9).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Consumer<ChannelPerformanceProvider>(
        builder: (context, provider, _) {
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: AutoTranslateText(provider.errorMessage));
          }

          final rewards = provider.data?.data?.rewards;
          final counts = provider.data?.data?.counts;

          final points = rewards?.points ?? 0;
          final unitsScanned = counts ?? 0;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Points Earned
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.orange, size: 24),
                        const SizedBox(width: 6),
                        Text(
                          points.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const AutoTranslateText("Points Earned", style: TextStyle(fontSize: 13)),
                  ],
                ),

                // Units Scanned
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_scanner,
                            color: AppColors.topBarColor, size: 24),
                        const SizedBox(width: 6),
                        Text(
                          unitsScanned.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const AutoTranslateText("Units Scanned", style: TextStyle(fontSize: 13)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
