import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import '../../../../common/app_colors.dart';

class FarmerDashboardProfileCard extends StatefulWidget {
  const FarmerDashboardProfileCard({super.key});

  @override
  State<FarmerDashboardProfileCard> createState() =>
      _FarmerDashboardProfileCardState();
}

class _FarmerDashboardProfileCardState
    extends State<FarmerDashboardProfileCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final channelProvider =
      Provider.of<ChannelPerformanceProvider>(context, listen: false);
      if (channelProvider.data == null) {
        channelProvider.fetchChannelPerformance();
      }

      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      final token = await SharedPrefsHelper.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Always fetch customer details, even if we have old data
        profileProvider.fetchCustomerDetails(token);
      }
    });
  }

    @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelProvider = Provider.of<ChannelPerformanceProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final rewards = channelProvider.data?.data?.rewards;
    final String points = rewards?.availablePoints?.toString() ?? '0';
    final String tier = 'GOLD';
    final String userName =
        profileProvider.decryptedCustomerData?.name ?? "User";

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        color: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(2), // padding for gradient border
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF8A2BE2), // Purple start
                Color(0xFFDA70D6), // Purple end
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: channelProvider.isLoading || profileProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : (channelProvider.errorMessage?.isNotEmpty ?? false)
                ? Center(child: AutoTranslateText(channelProvider.errorMessage!))
                : (profileProvider.errorMessage?.isNotEmpty ?? false)
                ? Center(child: AutoTranslateText(profileProvider.errorMessage!))
                : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Name + Points
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, $userName",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            points,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.topBarColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const AutoTranslateText(
                            "Points Balance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right side: Avatar + Tier
                Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (
                          profileProvider.decryptedCustomerData?.profilepicture != null &&
                              profileProvider.decryptedCustomerData!.profilepicture!.isNotEmpty
                      )
                          ? NetworkImage(
                        profileProvider.decryptedCustomerData!.profilepicture!,
                      )
                          : AssetImage("assets/images/crystal_logo.jpeg"),
                      onBackgroundImageError: (_, __) {},
                    ),

                    const SizedBox(height: 6),
                    AutoTranslateText(
                      tier,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
