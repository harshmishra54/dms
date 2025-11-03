import 'package:TrustTags_DMS/data/models/scheme_running_model.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/reward_claim_provider.dart';
import 'package:TrustTags_DMS/features/schemes/provider/scheme_running_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DistributorSchemes extends StatefulWidget {
  const DistributorSchemes({super.key});

  @override
  State<DistributorSchemes> createState() => _DistributorSchemesState();
}

class _DistributorSchemesState extends State<DistributorSchemes> {
  bool _isRedeeming = false; // Track redeem loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchemeRunningProvider>(context, listen: false)
          .fetchMyRewards();
      Provider.of<ChannelPerformanceProvider>(context, listen: false)
          .fetchChannelPerformance();
    });

  }

  Future<void> _onRedeemTap(BuildContext context, RewardData reward) async {
    if (_isRedeeming) return; // Ignore if already redeeming

    setState(() => _isRedeeming = true);

    final channelProvider =
    Provider.of<ChannelPerformanceProvider>(context, listen: false);
    final availablePoints =
        channelProvider.data?.data?.rewards?.availablePoints ?? 0;

    if (availablePoints < (reward.points ?? 0)) {
      final needed = (reward.points ?? 0) - availablePoints;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text("You need $needed more points to claim ${reward.name}."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isRedeeming = false);
      return;
    }

    final rewardProvider =
    Provider.of<GetMyRewardProvider>(context, listen: false);

    await rewardProvider.fetchMyReward(reward.id ?? "");

    if (rewardProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rewardProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reward ${reward.name} claimed successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh both rewards list and channel performance
      await Future.wait([
        Provider.of<SchemeRunningProvider>(context, listen: false)
            .fetchMyRewards(),
        Provider.of<ChannelPerformanceProvider>(context, listen: false)
            .fetchChannelPerformance(),
      ]);
    }

    setState(() => _isRedeeming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer2<SchemeRunningProvider, ChannelPerformanceProvider>(
          builder: (context, schemeProvider, channelProvider, child) {
            if (schemeProvider.isLoading && channelProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }


            if (schemeProvider.errorMessage != null ||
                (channelProvider.errorMessage?.isNotEmpty ?? false)) {
              final schemeError = schemeProvider.errorMessage;
              final channelError = channelProvider.errorMessage;

              if (schemeError != null &&
                  schemeError.toLowerCase().contains("resource not found")) {
                return const Center(
                  child: Text(
                    "No rewards found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return Center(
                child: Text(
                  schemeError ?? channelError ?? "Something went wrong",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (schemeProvider.rewards.isEmpty) {
              return const Center(
                child: Text(
                  "No rewards available",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: schemeProvider.rewards.length,
              itemBuilder: (context, index) {
                final RewardData reward = schemeProvider.rewards[index];
                final totalStock = reward.stock ?? 0;
                final redeemed = reward.redeemedStock ?? 0;
                final availableStock = totalStock - redeemed;
                final isOutOfStock = availableStock <= 0;

                return GestureDetector(
                  onTap:
                  isOutOfStock ? null : () => _onRedeemTap(context, reward),
                  child: Opacity(
                    opacity: isOutOfStock ? 0.5 : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                        Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Points Badge
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${reward.points} pts",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          // Reward Image
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: reward.image != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  reward.image!,
                                  fit: BoxFit.contain,
                                ),
                              )
                                  : const Icon(Icons.image,
                                  size: 70, color: Colors.grey),
                            ),
                          ),

                          // Reward Name
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              reward.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          // Stock Info
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              "In Stock: $availableStock",
                              style: TextStyle(
                                fontSize: 12,
                                color: (availableStock > 0)
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Redeem Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? Colors.grey.shade300
                                  : Colors.deepPurple.shade50,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(14),
                              ),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? "Out of Stock"
                                  : (_isRedeeming
                                  ? "Processing..."
                                  : "Redeem Now"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? Colors.grey.shade600
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),

        // Full-Screen Loader Overlay
        if (_isRedeeming)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            ),
          ),
      ],
    );
  }
}
