import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/points/providers/points_provider.dart';
import 'package:TrustTags_DMS/features/spinner/presentation/spinner.dart';
import 'package:TrustTags_DMS/features/spinner/provider/spinner_history_provider.dart';
import '../../../../common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointsSection extends StatefulWidget {
  const PointsSection({super.key});

  @override
  State<PointsSection> createState() => _PointsSectionState();
}

class _PointsSectionState extends State<PointsSection>
    with SingleTickerProviderStateMixin {
  String? userId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadUserAndFetch();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.01, end: 0.01).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadUserAndFetch() async {
    final id = await SharedPrefsHelper.getUserId();
    if (id != null && id.isNotEmpty) {
      setState(() => userId = id);
    }

    final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
    await pointsProvider.fetchScanHistory("1900-01-01", "2100-12-31");

    // ✅ Auto navigation removed, only fetch data
  }

  String maskCode(String? code) {
    if (code == null || code.isEmpty) return "-";
    if (code.length <= 4) return code;
    final start = code.substring(0, 2);
    final end = code.substring(code.length - 3);
    return "$start*****$end";
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PointsProvider, SpinnerHistoryProvider>(
      builder: (context, pointsProvider, spinnerProvider, _) {
        if (pointsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final history = pointsProvider.scanHistory;

        if (history.isEmpty) {
          return const Center(child: AutoTranslateText("No history found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];

            final date = item.createdAt ?? '';
            final dateTime = DateTime.tryParse(date);
            final formattedDate = dateTime != null
                ? DateFormat('dd MMM yyyy').format(dateTime)
                : "-";

            final adjusted = double.tryParse(item.totalAdjusted ?? "0") ?? 0.0;
            final points = double.tryParse(item.points ?? "0") ?? 0.0;
            final remaining = (points - adjusted).clamp(0, double.infinity);

            final product = item.product;
            final productName = product?.name ?? "-";
            final imageUrl = product?.mainImage ?? "";
            final schemeName = item.schemeName ?? "-";
            final uniqueCode = maskCode(item.uniqueCode);
            final level = item.level ?? "";

            // ✅ SPIN CONDITION (you already fixed)
            final hasSpinWheel = item.isspinwheel == true && item.isspin == false;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 4, left: 8, right: 8),
                  child: AutoTranslateText(
                    formattedDate,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),

                if (hasSpinWheel)
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: GestureDetector(
                            onTap: () async {
                              if (userId != null) {
                                await spinnerProvider.getSpinnerHistory(userId!);

                                if (spinnerProvider.spinnerHistory.isNotEmpty) {
                                  final spinnerItem =
                                      spinnerProvider.spinnerHistory.first;

                                  // ✅ Navigate only when user taps
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SpinnerWidget(
                                        spinnerId: spinnerItem.id!,
                                        segments: spinnerItem.segments ?? [],
                                      ),
                                    ),
                                  ).then((_) {
                                    context
                                        .read<PointsProvider>()
                                        .fetchScanHistory("1900-01-01", "2100-12-31");
                                  });
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.35),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.amber.shade300,
                                  width: 1.4,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(8),
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
                                        const Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Icon(
                                            Icons.auto_awesome,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          AutoTranslateText(
                                            productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          AutoTranslateText(level),
                                          AutoTranslateText(
                                            uniqueCode,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          AutoTranslateText(
                                            "🎁 Spin Available!",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amber.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoTranslateText(
                                  productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AutoTranslateText(level),
                                AutoTranslateText(
                                  uniqueCode,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                AutoTranslateText(schemeName),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: (adjusted > 0)
                                  ? Colors.orange
                                  : AppColors.topBarColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AutoTranslateText(
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

                if (!hasSpinWheel)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 12),
                    child: AutoTranslateText(
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
