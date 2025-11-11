import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/farmer_advocacy_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/farmer_advocacy_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/purchase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';

class FunnelStageDetailScreen extends StatefulWidget {
  final int stageIndex;
  final String stageName;

  const FunnelStageDetailScreen({
    super.key,
    required this.stageIndex,
    required this.stageName,
  });

  @override
  State<FunnelStageDetailScreen> createState() => _FunnelStageDetailScreenState();
}

class _FunnelStageDetailScreenState extends State<FunnelStageDetailScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Purchase + Retention use same API
    if (widget.stageIndex == 2 || widget.stageIndex == 3) {
      Future.microtask(() {
        Provider.of<PurchaseDataProvider>(context, listen: false)
            .fetchPurchaseData();
      });
    }

    // ✅ Advocacy API
    if (widget.stageIndex == 4) {
      Future.microtask(() {
        Provider.of<AdvocacyProvider>(context, listen: false).fetchAdvocacy();
      });
    }
  }

  List<FarmerFunnelData> _getFarmersForStage(
      List<FarmerFunnelData> allFarmers, int stageIndex) {
    switch (stageIndex) {
      case 0:
        return allFarmers;
      case 1:
        return allFarmers
            .where((f) => f.queries != null && f.queries!.isNotEmpty)
            .toList();
      case 2:
        return []; // Handled by purchase API
      case 3:
        return []; // Handled by purchase API (Retention)
      case 4:
        return []; // Advocacy handled separately
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final funnelProvider =
    Provider.of<FarmerFunnelProvider>(context, listen: false);
    final allFarmers = funnelProvider.farmerFunnel?.data ?? [];
    final farmersForStage = _getFarmersForStage(allFarmers, widget.stageIndex);

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

          /// ✅ --- PURCHASE STAGE (All purchases > 0) ---
          if (widget.stageIndex == 2)
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

                  final purchaseList = purchaseProvider.purchaseList
                      .where((p) => p.purchaseCount > 0)
                      .toList();

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
                            backgroundColor:
                            Colors.deepPurple.withOpacity(0.2),
                            child: const Icon(Icons.shopping_bag,
                                color: Colors.deepPurple),
                          ),
                          title: AutoTranslateText(
                            purchase.farmerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
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

          /// ✅ --- RETENTION STAGE (purchaseCount > 1) ---
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

                  final retentionList = purchaseProvider.purchaseList
                      .where((p) => p.purchaseCount > 1)
                      .toList();

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
                            backgroundColor:
                            Colors.green.withOpacity(0.2),
                            child: const Icon(Icons.repeat,
                                color: Colors.green),
                          ),
                          title: AutoTranslateText(
                            purchase.farmerName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
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

          /// ✅ --- ADVOCACY STAGE ---

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

                    // ✅ Group farmers by referred_by_name
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
                                contentPadding: const EdgeInsets.only(left: 72, right: 16),
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
              )

            /// ✅ --- OTHER STAGES ---
            else
              Expanded(
                child: farmersForStage.isEmpty
                    ? const Center(
                  child: AutoTranslateText(
                    'No farmers found for this stage',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: farmersForStage.length,
                  itemBuilder: (context, index) {
                    final farmer = farmersForStage[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                          Colors.deepPurple.withOpacity(0.2),
                          child: const Icon(Icons.person,
                              color: Colors.deepPurple),
                        ),
                        title: AutoTranslateText(
                          farmer.farmerName ?? 'Unnamed Farmer',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        subtitle: AutoTranslateText(
                          farmer.mobileNumber ?? "No Mobile",
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
