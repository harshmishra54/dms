import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/milestone_provider.dart';
import '../../../../common/app_colors.dart';
import 'package:TrustTags_DMS/data/models/milestone_response.dart';

class PointsSection extends StatefulWidget {
  const PointsSection({super.key});

  @override
  State<PointsSection> createState() => _PointsSection();
}

class _PointsSection extends State<PointsSection>
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
    ).animate(CurvedAnimation(parent: _borderController, curve: Curves.easeInOut));
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

    // Fetch fresh data every time the widget appears
    final channelProvider = Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final milestoneProvider = Provider.of<MilestoneProvider>(context, listen: false);

    channelProvider.fetchChannelPerformance();
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
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderColorAnimation.value ?? Colors.amber,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(0),
            child: Consumer3<ProfileProvider, ChannelPerformanceProvider, MilestoneProvider>(
              builder: (context, profileProvider, channelProvider, milestoneProvider, child) {
                final rewards = channelProvider.data?.data?.rewards;
                final int availablePoints = rewards?.availablePoints ?? 0;
                final String tier = 'GOLD';

                final displayName =
                    profileProvider.decryptedCustomerData?.name ?? userName;

                // milestones
                final milestones = milestoneProvider.milestones;
                milestones.sort((a, b) => a.value.compareTo(b.value));
                final nextMilestone = milestones.firstWhere(
                      (m) => availablePoints < m.value,
                  orElse: () => milestones.isNotEmpty
                      ? milestones.last
                      : MilestoneData(value: 0, label: "No Milestone", image: ""),
                );
                final neededPoints =
                (nextMilestone.value - availablePoints).clamp(0, double.infinity).toInt();

                int maxValue = milestones.isNotEmpty ? milestones.last.value : availablePoints;
                double progress = (availablePoints / maxValue).clamp(0, 1).toDouble();

                if (profileProvider.isLoading || milestoneProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // top row
                    // top row with shaded background for name, role, and logo only
                    Container(
                      width: double.infinity, // takes full width of parent card
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50], // light purple shade
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded( // <-- make text column flexible
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
                                  "Retailer",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8), // spacing between text and avatar
                          const CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage("assets/images/trust_tags.png"),
                          ),
                        ],
                      ),
                    ),
// then show points below separately
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        availablePoints.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.topBarColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: const Text(
                        "Points",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),



                    // reward info
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
                        padding: const EdgeInsets.only(left: 12.0,right: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0DFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              AutoTranslateText(
                                neededPoints > 0
                                    ? "Next Reward: ${nextMilestone.label} Need $neededPoints More Points"
                                    : "Next Reward: ${nextMilestone.label} - Unlocked!",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Colors.purpleAccent,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // rewards progress
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
                                    errorBuilder: (c, e, s) =>
                                    const Icon(Icons.image_not_supported,
                                        size: 32, color: Colors.grey),
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
                                // Background
                                Container(
                                  color: Colors.purple[100],
                                ),
                                // Foreground (progress)
                                FractionallySizedBox(
                                  widthFactor: progress, // value between 0 and 1
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF9C27B0), // start purple
                                          Color(0xFFE040FB), // end purple
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
                            return Expanded( // <-- flexible width
                              child: AutoTranslateText(
                                m.label,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis, // keep in one line
                                maxLines: 1, // never wrap to 2nd line
                              ),
                            );
                          }).toList(),
                        ),


                      ],
                    ),

                    const SizedBox(height: 20),

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
