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

        // Stats section with cards + progress bar
        SizedBox(
          height: 120,
          width: double.infinity,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => selectedIndex = index);
            },
            children: [
              _buildStatsPage("50,000", "27,000"),
              _buildStatsPage("1,20,000", "75,000"),
              _buildStatsPage("5,00,000", "4,10,000"),
            ],
          ),
        ),
      ],
    );
  }

  /// Each page contains Target + Sales card + ONE progress bar
  Widget _buildStatsPage(String target, String sales) {
    double targetValue = _parseNumber(target);
    double salesValue = _parseNumber(sales);

    double progress = 0.0;
    if (targetValue > 0) {
      progress = (salesValue / targetValue).clamp(0.0, 1.0);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard(targetValue.toStringAsFixed(0), "TARGET", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DistributorListScreen(),
                ),
              );
            }),
            _buildStatCard(salesValue.toStringAsFixed(0), "SALES", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DistributorListScreen(),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        // Gradient Progress Bar with percentage inside
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
                    width: fullWidth * progress, // Use exact width
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.purpleAccent,
                          Color(0xFF9C27B0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                          color: Colors.white,
                          fontSize: 10,
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

  /// Convert "1,20,000" into 120000
  double _parseNumber(String value) {
    return double.tryParse(value.replaceAll(",", "")) ?? 0.0;
  }

  /// Small card widget
  /// Small card widget
  Widget _buildStatCard(String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        final roleId = await SharedPrefsHelper.getRoleId();
        final userId = await SharedPrefsHelper.getUserId();

        if (roleId == 1) {
          // ✅ Distributor → go directly
          if (label == "TARGET") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductListingScreen()),
            );
          } else if (label == "SALES") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AchievedTargetListingScreen()),
            );
          }
          return;
        }

        if (roleId == 19 && userId != null) {
          // RSM → Fetch TSI List
          final provider = Provider.of<TsiListProvider>(context, listen: false);
          await provider.fetchTsiList(userId);

          if (provider.tsiUsers.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: AutoTranslateText("No TSI found")),
            );
            return;
          }

          // Show BottomSheet for TSI selection
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              return Consumer<TsiListProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
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
                          Navigator.pop(ctx); // close sheet
                          // Navigate to distributor list screen with TSI ID
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
          // Other roles → Distributor list
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DistributorListScreen()),
          );
        }
      },
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        child: Container(
          width: 130,
          height: 70,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoTranslateText(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

