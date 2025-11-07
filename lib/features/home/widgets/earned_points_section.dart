import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';

class EarnedPointsSection extends StatefulWidget {
  final double earnedPoints;
  final int scanCodes;

  const EarnedPointsSection({
    super.key,
    required this.earnedPoints,
    required this.scanCodes,
  });

  @override
  State<EarnedPointsSection> createState() => _EarnedPointsSectionState();
}

class _EarnedPointsSectionState extends State<EarnedPointsSection>
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(1), // super thin border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // almost same as card
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: child,
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Earned Points Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.military_tech,
                            size: 20, color: Colors.orange),
                        const SizedBox(width: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.earnedPoints.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const AutoTranslateText(
                      "Earned Points",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 50,
                width: 1,
                color: Colors.grey.shade300,
              ),

              // Scan Codes Column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_2,
                            size: 20, color: AppColors.topBarColor),
                        const SizedBox(width: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.scanCodes.toString(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const AutoTranslateText(
                      "Scan Codes",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
