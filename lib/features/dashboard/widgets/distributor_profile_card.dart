import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/milestone_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/my_category_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/tab_stat_section.dart';
import '../../../../common/app_colors.dart';
import 'package:TrustTags_DMS/data/models/milestone_response.dart';


Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case "silver":
      return const Color(0xFFC0C0C0); // silver
    case "gold":
      return const Color(0xFFD4AF37); // gold
    case "platinum":
      return const Color(0xFFB0E0E6); // platinum (light blue)
    case "diamond":
      return const Color(0xFF9B59B6); // purple diamond
    default:
      return Colors.black; // fallback
  }
}


class DistributorProfileCard extends StatefulWidget {
  const DistributorProfileCard({super.key});

  @override
  State<DistributorProfileCard> createState() => _DistributorProfileCardState();
}

class _DistributorProfileCardState extends State<DistributorProfileCard>
    with TickerProviderStateMixin {
  String userName = "User";

  late AnimationController _borderController;
  late Animation<Color?> _borderColorAnimation;

  late AnimationController _rewardController;
  late Animation<double> _rewardScaleAnimation;
  late Animation<double> _rewardFadeAnimation;

  @override
  void initState() {
    super.initState();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _borderColorAnimation = ColorTween(
      begin: const Color(0xFFD4AF37),
      end: Colors.purple,
    ).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );
    _borderController.repeat(reverse: true);

    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rewardScaleAnimation = Tween<double>(begin: 0.95, end: 1.0)
        .animate(CurvedAnimation(parent: _rewardController, curve: Curves.easeOut));
    _rewardFadeAnimation = Tween<double>(begin: 0, end: 1.0)
        .animate(CurvedAnimation(parent: _rewardController, curve: Curves.easeIn));
    _rewardController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final channelProvider =
    Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    final milestoneProvider =
    Provider.of<MilestoneProvider>(context, listen: false);
    final categoryProvider =
    Provider.of<MyCategoryProvider>(context, listen: false);

    channelProvider.fetchChannelPerformance().then((_) {
      final pts = channelProvider.data?.data?.rewards?.points ?? 0;
      categoryProvider.getMyCategory(pts);
    });

    milestoneProvider.fetchMilestones();

    SharedPrefsHelper.getAccessToken().then((token) {
      if (token != null) {
        profileProvider.fetchCustomerDetails(token);
      }
    });

    SharedPrefsHelper.getUserName().then((name) {
      if (name != null && mounted) {
        setState(() {
          userName = name;
        });
      }
    });
  }

  @override
  void dispose() {
    _borderController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return Card(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderColorAnimation.value ?? Colors.amber,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: Consumer3<ProfileProvider, ChannelPerformanceProvider,
                MilestoneProvider>(
              builder: (context, profileProvider, channelProvider,
                  milestoneProvider, child) {
                final rewards = channelProvider.data?.data?.rewards;
                final int availablePoints = rewards?.availablePoints ?? 0;

                final myCategory =
                    Provider.of<MyCategoryProvider>(context).categoryData;

                final currentCategory =
                    myCategory?.currentCategory ?? "—";
                final nextCategory =
                    myCategory?.nextCategory ?? "—";
                final nextCategoryPoints =
                    myCategory?.pointsRequiredForNextCategory ?? 0;
                final currentCategoryColor = getCategoryColor(currentCategory);
                final nextCategoryColor = getCategoryColor(nextCategory);


                final displayName =
                    profileProvider.decryptedCustomerData?.name ?? userName;

                final milestones = milestoneProvider.milestones;
                milestones.sort((a, b) => a.value.compareTo(b.value));
                final nextMilestone = milestones.firstWhere(
                      (m) => availablePoints < m.value,
                  orElse: () => milestones.isNotEmpty
                      ? milestones.last
                      : MilestoneData(
                      value: 0, label: "No Milestone", image: ""),
                );
                final neededPoints =
                (nextMilestone.value - availablePoints).clamp(0, double.infinity).toInt();

                int maxValue =
                milestones.isNotEmpty ? milestones.last.value : availablePoints;
                double progress =
                (availablePoints / maxValue).clamp(0, 1).toDouble();

                if (profileProvider.isLoading || milestoneProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header With Name / Avatar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hii $displayName",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                const AutoTranslateText(
                                  "Distributor",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: (
                                profileProvider
                                    .decryptedCustomerData
                                    ?.profilepicture !=
                                    null &&
                                    profileProvider
                                        .decryptedCustomerData!
                                        .profilepicture!
                                        .isNotEmpty)
                                ? NetworkImage(
                              profileProvider
                                  .decryptedCustomerData!
                                  .profilepicture!,
                            )
                                : const AssetImage(
                                "assets/images/trust_tags.png")
                            as ImageProvider,
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ⭐⭐⭐ DYNAMIC CATEGORY ROW ⭐⭐⭐
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "$currentCategory ",
                                  style:  TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: currentCategoryColor,
                                  ),
                                ),
                                TextSpan(
                                  text: "$availablePoints ",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.topBarColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 18.0),
                          child: Text(
                            "$nextCategory @ $nextCategoryPoints Points",
                            style:  TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: nextCategoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Reward Info
                    AnimatedBuilder(
                      animation: _rewardController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _rewardFadeAnimation.value,
                          child: Transform.scale(
                            scale: _rewardScaleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0DFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Next Reward: ${nextMilestone.label} "
                                "${neededPoints > 0 ? "Need $neededPoints More Points" : "Unlocked!"}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.purpleAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Milestone Section (UNTOUCHED)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: milestones.map((m) {
                            final unlocked = availablePoints >= m.value;
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    m.image,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.image_not_supported,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                if (unlocked)
                                  const Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: 12,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Container(color: Colors.purple[100]),
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF9C27B0),
                                          Color(0xFFE040FB),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: milestones.map((m) {
                            return Expanded(
                              child: AutoTranslateText(
                                m.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: TabStatSection(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
