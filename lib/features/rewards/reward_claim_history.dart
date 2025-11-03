// reward_claim_history_screen.dart

import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/rewards/provider/reward_claim_history_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RewardClaimHistoryScreen extends StatefulWidget {
  const RewardClaimHistoryScreen({super.key});

  @override
  State<RewardClaimHistoryScreen> createState() =>
      _RewardClaimHistoryScreenState();
}

class _RewardClaimHistoryScreenState extends State<RewardClaimHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RewardClaimHistoryProvider>().fetchRewardClaimHistory();
    });
  }

  String _getStatusText(int? status) {
    switch (status) {
      case 0:
        return "Pending";
      case 1:
        return "Rejected";
      case 2:
        return "Approved";
      default:
        return "Unknown";
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.red;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDetailsDialog(BuildContext context, dynamic item) {
    if (item.isVerified == 1) {
      // Rejected → Show verify comment
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Reward Rejected"),
          content: Text(item.verifyComment?.isNotEmpty == true
              ? item.verifyComment!
              : "No reason provided."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    } else if (item.isVerified == 2) {
      // Approved → Show partnerName & transactionId
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Reward Approved"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Partner: ${item.partnerName ?? 'N/A'}"),
              const SizedBox(height: 6),
              Text("Transaction ID: ${item.transactionId ?? 'N/A'}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RewardClaimHistoryProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const AppStatusBar(),
          // Custom App Bar
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Reward Claim History',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: Text(provider.errorMessage!));
                }

                final historyList = provider.response?.data ?? [];

                if (historyList.isEmpty) {
                  return const Center(
                    child: Text("No reward claim history found."),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = historyList[index];

                    return GestureDetector(
                      onTap: () => _showDetailsDialog(context, item),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reward Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.voucherImage != null &&
                                    item.voucherImage!.isNotEmpty
                                    ? Image.network(
                                  item.voucherImage!,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                      Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                                    : Container(
                                  width: 70,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.card_giftcard,
                                    color: Colors.blue,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reward name + Status
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.reward?.name ?? "Reward",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (item.isVerified != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                  item.isVerified)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                              BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _getStatusText(item.isVerified),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(
                                                    item.isVerified),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // Date
                                    Text(
                                      item.createdAt != null
                                          ? "Date: ${item.createdAt!.split("T").first}"
                                          : "Date: N/A",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
