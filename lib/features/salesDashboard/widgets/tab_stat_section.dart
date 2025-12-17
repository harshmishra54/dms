import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/salesDashboard/distributorlistoftarget_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_list_for_rsm_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tabs/achieved_card.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tabs/target_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';

class TabStatSection extends StatefulWidget {
  const TabStatSection({super.key});

  @override
  State<TabStatSection> createState() => _TabStatSectionState();
}

class _TabStatSectionState extends State<TabStatSection> {
  final List<String> tabs = ["Month", "Quarter", "Year"];
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab section
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF9F2FC),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: List.generate(tabs.length, (index) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onTabChanged(index),
                    child: Column(
                      children: [
                        AutoTranslateText(
                          tabs[index],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: selectedIndex == index
                                ? AppColors.primaryPurple
                                : Colors.grey,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: selectedIndex == index ? 40 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Stats section
        LayoutBuilder(
          builder: (context, constraints) {
            final textScale = MediaQuery
                .of(context)
                .textScaleFactor;

            return SizedBox(
              height: 110 * textScale.clamp(1.0, 1.25),
              width: double.infinity,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => selectedIndex = index);
                },
                children: const [
                  _StatsPage(target: "50,000", sales: "27,000"),
                  _StatsPage(target: "1,20,000", sales: "75,000"),
                  _StatsPage(target: "5,00,000", sales: "4,10,000"),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// ========================
/// STATS PAGE
/// ========================
class _StatsPage extends StatelessWidget {
  final String target;
  final String sales;

  const _StatsPage({
    required this.target,
    required this.sales,
  });

  @override
  Widget build(BuildContext context) {
    final targetValue = _parseNumber(target);
    final salesValue = _parseNumber(sales);

    final progress =
    targetValue > 0 ? (salesValue / targetValue).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatCard(
              value: targetValue.toStringAsFixed(0),
              label: "TARGET",
            ),
            _StatCard(
              value: salesValue.toStringAsFixed(0),
              label: "SALES",
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              return Stack(
                children: [
                  Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 15,
                    width: fullWidth * progress,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.purpleAccent,
                          Color(0xFF9C27B0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: AutoTranslateText(
                        "${(progress * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static double _parseNumber(String value) {
    return double.tryParse(value.replaceAll(",", "")) ?? 0.0;
  }
}

/// ========================
/// RESPONSIVE STAT CARD
/// ========================
class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardHeight =
        screenHeight * 0.085 * textScale.clamp(1.0, 1.3);

    return GestureDetector(
      onTap: () async {
        final roleId = await SharedPrefsHelper.getRoleId();
        final userId = await SharedPrefsHelper.getUserId();

        if (roleId == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => label == "TARGET"
                  ? ProductListingScreen()
                  : AchievedTargetListingScreen(),
            ),
          );
          return;
        }

        if (roleId == 19 && userId != null) {
          final provider =
          Provider.of<TsiListProvider>(context, listen: false);
          await provider.fetchTsiList(userId);

          if (provider.tsiUsers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: AutoTranslateText("No TSI found")),
            );
            return;
          }

          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              return Consumer<TsiListProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.tsiUsers.length,
                    itemBuilder: (ctx, index) {
                      final tsi = provider.tsiUsers[index];
                      return ListTile(
                        title: AutoTranslateText(tsi.name ?? "Unknown"),
                        subtitle: AutoTranslateText(tsi.mobileNo ?? ""),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DistributorListScreen(tsiId: tsi.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DistributorListScreen(),
            ),
          );
        }
      },
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Container(
          width: 130,
          height: cardHeight,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AutoTranslateText(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
