import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
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
  State<FunnelStageDetailScreen> createState() =>
      _FunnelStageDetailScreenState();
}

class _FunnelStageDetailScreenState extends State<FunnelStageDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch Purchase Data only if Purchase stage is opened
    if (widget.stageIndex == 2) {
      Future.microtask(() {
        final provider =
        Provider.of<PurchaseDataProvider>(context, listen: false);
        provider.fetchPurchaseData(""); // Fetch purchase data (global)
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
        return []; // handled separately by new API
      case 3:
        return allFarmers
            .where((f) =>
        f.recommendedProducts != null &&
            f.recommendedProducts!.isNotEmpty)
            .toList();
      case 4:
        return allFarmers
            .where((f) =>
        f.status?.toLowerCase() == 'active' || f.meetingId != null)
            .toList();
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
                      widget.stageIndex == 2
                          ? 'Purchase Details'
                          : 'Sale Details',
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

          /// --- PURCHASE STAGE ---
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

                  // ✅ Filter only farmers with purchaseCount > 0
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
                            'Purchase Products: ${purchase.purchaseCount}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          else
          /// --- OTHER STAGES ---
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
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        unselectedWidgetColor: Colors.black87,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor:
                          Colors.deepPurple.withOpacity(0.2),
                          child: const Icon(Icons.person,
                              color: Colors.deepPurple),
                        ),
                        title: AutoTranslateText(
                          farmer.farmerName ?? 'Unnamed Farmer',
                          style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: AutoTranslateText(
                          farmer.mobileNumber != null
                              ? 'Mobile: ${farmer.mobileNumber}'
                              : 'No mobile available',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                if (farmer.villageName != null)
                                  AutoTranslateText('Village: ${farmer.villageName}',
                                      style: const TextStyle(
                                          color: Colors.black54)),
                                const SizedBox(height: 8),
                                if (farmer.crops != null &&
                                    farmer.crops!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const AutoTranslateText('Crops & Products:',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight:
                                              FontWeight.bold)),
                                      ...farmer.crops!.map((crop) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              AutoTranslateText(
                                                  '- Crop: ${crop.cropName ?? "N/A"}',
                                                  style: const TextStyle(
                                                      color:
                                                      Colors.black54)),
                                              if (crop.products != null &&
                                                  crop.products!
                                                      .isNotEmpty)
                                                ...crop.products!.map(
                                                      (product) => Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 8,
                                                        top: 2),
                                                    child: AutoTranslateText(
                                                        '• ${product.productName ?? "Unnamed"} (${product.expectedQuantity ?? "-"})',
                                                        style:
                                                        const TextStyle(
                                                            color: Colors
                                                                .black54)),
                                                  ),
                                                )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),

                                /// --- QUERIES (for Consideration stage) ---
                                if (widget.stageIndex == 1 &&
                                    farmer.queries != null &&
                                    farmer.queries!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const AutoTranslateText('Queries:',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight:
                                              FontWeight.bold)),
                                      ...farmer.queries!.map((query) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              if (query.details != null &&
                                                  query.details!
                                                      .isNotEmpty)
                                                ...query.details!.map(
                                                      (detail) => Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .only(
                                                        left: 8,
                                                        top: 2),
                                                    child: AutoTranslateText(
                                                        '• ${detail.productName ?? "N/A"} | Crop: ${detail.crop ?? "-"} | Quantity: ${detail.quantity ?? "-"} | Reason: ${detail.reason ?? "-"}',
                                                        style:
                                                        const TextStyle(
                                                            color: Colors
                                                                .black54)),
                                                  ),
                                                )
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
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
