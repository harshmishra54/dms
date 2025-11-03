import 'package:TrustTags_DMS/features/authentication/provider/scheme_wise_points_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/channel_performance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/app_colors.dart';

class SchemesTabSection extends StatefulWidget {
  const SchemesTabSection({super.key});

  @override
  State<SchemesTabSection> createState() => _SchemesTabSectionState();
}

class _SchemesTabSectionState extends State<SchemesTabSection> {
  final Map<int, Map<String, String>> schemePointsData = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final channelProvider =
      Provider.of<ChannelPerformanceProvider>(context, listen: false);
      final offerPointProvider =
      Provider.of<OfferPointProvider>(context, listen: false);

      // Fetch all schemes
      await channelProvider.fetchChannelPerformance();
      final offers = channelProvider.data?.data?.offers ?? [];

      if (offers.isNotEmpty) {
        for (var i = 0; i < offers.length; i++) {
          final id = offers[i].id;
          if (id != null) {
            await offerPointProvider.fetchOfferPoints(id);

            schemePointsData[i] = {
              "earned": offerPointProvider.offerPoint?.data?.points ?? "0",
              "available":
              offerPointProvider.offerPoint?.data?.availablePoints ?? "0",
              "redeemed":
              offerPointProvider.offerPoint?.data?.utilizePoints ?? "0",
            };
          } else {
            schemePointsData[i] = {
              "earned": "0",
              "available": "0",
              "redeemed": "0",
            };
          }
        }
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final spacing = 16.0;
    final cardCount = 3;
    final totalSpacing = spacing * (cardCount - 1);
    final cardWidth = (screenWidth - 32 - totalSpacing) / cardCount;
    // 32 = padding left+right of SingleChildScrollView

    return Consumer2<ChannelPerformanceProvider, OfferPointProvider>(
      builder: (context, channelPerformanceProvider, offerPointProvider, child) {
        if (channelPerformanceProvider.isLoading || offerPointProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (channelPerformanceProvider.errorMessage.isNotEmpty) {
          return Center(child: Text(channelPerformanceProvider.errorMessage));
        }

        final offers = channelPerformanceProvider.data?.data?.offers ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Running Schemes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Table of schemes
              Container(
                decoration: _boxDecoration(),
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth;
                    final numericColumnWidth = 60.0;
                    final imageWidth = 40.0;
                    final spacingRow = 6.0;
                    final schemeColumnWidth =
                        maxWidth - (numericColumnWidth * 3) - imageWidth - spacingRow - 16;

                    return DataTable(
                      columnSpacing: 8,
                      horizontalMargin: 8,
                      headingRowColor: MaterialStateProperty.all(
                        Colors.grey.shade200.withOpacity(0.6),
                      ),
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: schemeColumnWidth,
                            child: const Text(
                              'Scheme',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: numericColumnWidth,
                            child: const Center(
                              child: Text(
                                'Earned',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: numericColumnWidth,
                            child: const Center(
                              child: Text(
                                'Redeem',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: numericColumnWidth,
                            child: const Center(
                              child: Text(
                                'Available',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          numeric: true,
                        ),
                      ],
                      rows: offers.asMap().entries.map((entry) {
                        final i = entry.key;
                        final scheme = entry.value;
                        final schemePoints = schemePointsData[i] ?? {
                          "earned": "0",
                          "available": "0",
                          "redeemed": "0"
                        };

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      scheme.schemeImage ?? '',
                                      width: imageWidth,
                                      height: 28,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        width: imageWidth,
                                        height: 28,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: spacingRow),
                                  SizedBox(
                                    width: schemeColumnWidth - imageWidth - spacingRow,
                                    child: Text(
                                      scheme.name ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: numericColumnWidth,
                                child: Center(
                                  child: Text(
                                    schemePoints["earned"] ?? "0",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: numericColumnWidth,
                                child: Center(
                                  child: Text(
                                    schemePoints["redeemed"] ?? "0",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: numericColumnWidth,
                                child: Center(
                                  child: Text(
                                    schemePoints["available"] ?? "0",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Redeem Points Via',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _RedeemOptionCard(
                    width: cardWidth,
                    title: 'Vouchers',
                    icon: Icons.card_giftcard,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming Soon')),
                      );
                    },
                  ),
                  SizedBox(width: spacing),
                  _RedeemOptionCard(
                    width: cardWidth,
                    title: 'Get Money',
                    icon: Icons.currency_rupee_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming Soon')),
                      );
                    },
                  ),
                  SizedBox(width: spacing),
                  _RedeemOptionCard(
                    width: cardWidth,
                    title: 'Rewards',
                    icon: Icons.emoji_events,
                    onTap: () {
                      DefaultTabController.of(context)?.animateTo(2);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300, width: 0.8),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

// --- Redeem Option Card ---
class _RedeemOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final double width;

  const _RedeemOptionCard({
    required this.title,
    required this.icon,
    this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 0.8),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.topBarColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
