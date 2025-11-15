import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/farmer_advocacy_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_advocacy_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/purchase_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_consideration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';
import 'package:intl/intl.dart';

class FunnelStageDetailScreen extends StatefulWidget {
  final int stageIndex;
  final String stageName;

  const FunnelStageDetailScreen({
    super.key,
    required this.stageIndex,
    required this.stageName,
  });

  @override
  State<FunnelStageDetailScreen> createState() =>
      _FunnelStageDetailScreenState();
}

class _FunnelStageDetailScreenState extends State<FunnelStageDetailScreen> {
  @override
  void initState() {
    super.initState();

    // PURCHASE STAGE
    if (widget.stageIndex == 2 || widget.stageIndex == 3) {
      Future.microtask(() {
        Provider.of<PurchaseDataProvider>(context, listen: false)
            .fetchPurchaseData();
      });
    }

    // ADVOCACY STAGE
    if (widget.stageIndex == 4) {
      Future.microtask(() {
        Provider.of<AdvocacyProvider>(context, listen: false).fetchAdvocacy();
      });
    }

    // CONSIDERATION STAGE
    if (widget.stageIndex == 1) {
      Future.microtask(() {
        Provider.of<FarmerConsiderationProvider>(context, listen: false)
            .fetchConsideration(
          createdBy: "6b63eacb-0e79-4f97-a580-3f4948546921", // replace dynamically if needed
        );
      });
    }
  }

  List<FarmerFunnelData> _getFarmersForStage(
      List<FarmerFunnelData> allFarmers, int stageIndex) {
    switch (stageIndex) {
      case 0:
        return allFarmers;
      case 1:
      case 2:
      case 3:
      case 4:
      default:
        return [];
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),
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
                  Expanded(
                    child: AutoTranslateText(
                      widget.stageName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // STAGE 0: Funnel
          if (widget.stageIndex == 0)
            Expanded(
              child: Consumer<FarmerFunnelProvider>(
                builder: (context, funnelProvider, _) {
                  if (funnelProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allFarmers = funnelProvider.farmerFunnel?.data ?? [];
                  if (allFarmers.isEmpty) {
                    return const Center(
                      child: AutoTranslateText(
                        'No farmers found for this stage',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  final farmersForStage =
                  _getFarmersForStage(allFarmers, widget.stageIndex);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: farmersForStage.length,
                    itemBuilder: (context, index) {
                      final farmer = farmersForStage[index];
                      final showDetails = widget.stageIndex == 0;

                      return ExpansionTile(
                        title: AutoTranslateText(
                          farmer.farmerName ?? 'Unnamed Farmer',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: AutoTranslateText(
                          farmer.mobileNumber ?? "No Mobile",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        children: showDetails && farmer.entries != null
                            ? farmer.entries!.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                AutoTranslateText(
                                    "Status: ${entry.status ?? 'N/A'}"),
                                AutoTranslateText(
                                    "Date: ${formatDate(entry.createdAt)}"),
                                const SizedBox(height: 6),
                                if (entry.crops != null &&
                                    entry.crops!.isNotEmpty)

                                const Divider(),
                              ],
                            ),
                          );
                        }).toList()
                            : [],
                      );
                    },
                  );
                },
              ),
            )

          // STAGE 1: Consideration
          else if (widget.stageIndex == 1)
            Expanded(
              child: Consumer<FarmerConsiderationProvider>(
                builder: (context, considerationProvider, _) {
                  if (considerationProvider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (considerationProvider.error != null) {
                    return Center(
                      child: AutoTranslateText(
                        considerationProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final farmers = considerationProvider.farmers;
                  if (farmers.isEmpty) {
                    return const Center(
                      child: AutoTranslateText(
                        'No farmers found for consideration.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: farmers.length,
                    itemBuilder: (context, index) {
                      final farmer = farmers[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.topBarColor,
                            child:
                            const Icon(Icons.person, color: Colors.white),
                          ),
                          title: AutoTranslateText(
                            farmer.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )

          // STAGE 2: Purchase
          else if (widget.stageIndex == 2)
              Expanded(
                child: Consumer<PurchaseDataProvider>(
                  builder: (context, purchaseProvider, _) {
                    if (purchaseProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (purchaseProvider.errorMessage != null) {
                      return Center(
                        child: AutoTranslateText(
                          purchaseProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final purchaseList =
                    purchaseProvider.purchaseList.where((p) => p.purchaseCount > 0).toList();
                    if (purchaseList.isEmpty) {
                      return const Center(
                        child: AutoTranslateText(
                          'No purchase data found.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: purchaseList.length,
                      itemBuilder: (context, index) {
                        final purchase = purchaseList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple.withOpacity(0.2),
                              child: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                            ),
                            title: AutoTranslateText(
                              purchase.farmerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            subtitle: AutoTranslateText(
                              'Purchase Count: ${purchase.purchaseCount}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )

            // STAGE 3: Retention
            else if (widget.stageIndex == 3)
                Expanded(
                  child: Consumer<PurchaseDataProvider>(
                    builder: (context, purchaseProvider, _) {
                      if (purchaseProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (purchaseProvider.errorMessage != null) {
                        return Center(
                          child: AutoTranslateText(
                            purchaseProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      final retentionList =
                      purchaseProvider.purchaseList.where((p) => p.purchaseCount > 1).toList();
                      if (retentionList.isEmpty) {
                        return const Center(
                          child: AutoTranslateText(
                            'No retention farmers found.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: retentionList.length,
                        itemBuilder: (context, index) {
                          final purchase = retentionList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.withOpacity(0.2),
                                child: const Icon(Icons.repeat, color: Colors.green),
                              ),
                              title: AutoTranslateText(
                                purchase.farmerName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              subtitle: AutoTranslateText(
                                'Repeat Purchases: ${purchase.purchaseCount}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                )

              // STAGE 4: Advocacy
              else if (widget.stageIndex == 4)
                  Expanded(
                    child: Consumer<AdvocacyProvider>(
                      builder: (context, advocacyProvider, _) {
                        if (advocacyProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (advocacyProvider.errorMessage != null) {
                          return Center(
                            child: AutoTranslateText(
                              advocacyProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        final referredList = advocacyProvider.advocacyResponse?.data ?? [];
                        if (referredList.isEmpty) {
                          return const Center(
                            child: AutoTranslateText(
                              'No referred farmers found.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          );
                        }
                        Map<String, List<ReferredFarmer>> grouped = {};
                        for (var farmer in referredList) {
                          grouped.putIfAbsent(farmer.refferedByName, () => []);
                          grouped[farmer.refferedByName]!.add(farmer);
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: grouped.keys.length,
                          itemBuilder: (context, index) {
                            final referredByName = grouped.keys.elementAt(index);
                            final farmers = grouped[referredByName]!;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple.withOpacity(0.2),
                                  child: const Icon(Icons.person, color: Colors.deepPurple),
                                ),
                                title: AutoTranslateText(
                                  referredByName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                subtitle: AutoTranslateText(
                                  "Total Referred: ${farmers.length}",
                                  style: const TextStyle(color: Colors.black54),
                                ),
                                children: farmers.map((farmer) {
                                  return ListTile(
                                    contentPadding:
                                    const EdgeInsets.only(left: 72, right: 16),
                                    leading: const Icon(Icons.arrow_right, color: Colors.grey),
                                    title: AutoTranslateText(
                                      farmer.name,
                                      style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.w500),
                                    ),
                                  );
                                }).toList(),
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
