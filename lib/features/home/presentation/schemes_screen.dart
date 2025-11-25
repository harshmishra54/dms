import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/schemes/presentation/distributor_schemes.dart';
import 'package:flutter/material.dart';
import '../widgets/schemes_tab_section.dart';
import '../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Top green status bar
            const AppStatusBar(),

            // Elevated Header + Tabs section
            Material(
              elevation: 5, // This makes the section elevated
              shadowColor: Colors.black26,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row (Schemes text + logo)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AutoTranslateText(
                          'Schemes',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Image.asset(
                          'assets/images/crystal_logo.jpeg',
                          height: 40,
                          width: 45,
                        ),
                      ],
                    ),
                  ),

                  // Tab bar with gray background
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: const TabBar(
                      labelColor: AppColors.topBarColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.topBarColor,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.card_giftcard),
                          text: 'Schemes',
                        ),
                        Tab(
                          icon: Icon(Icons.videogame_asset),
                          text: 'Games',
                        ),
                        Tab(
                          icon: Icon(Icons.emoji_events),
                          text: 'Rewards',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab contents
            Expanded(
              child: TabBarView(
                children: [
                  const SchemesTabSection(),
                  const Center(
                    child: AutoTranslateText(
                      'Coming Soon',
                      style: TextStyle(
                        color: AppColors.topBarColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // ✅ Rewards tab content
                  DistributorSchemes(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
