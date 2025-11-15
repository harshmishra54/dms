import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/funnel_data_provider.dart';
import 'package:TrustTags_DMS/data/models/farmer_funnel_model.dart';

class FarmerFunnelDashboard extends StatefulWidget {
  const FarmerFunnelDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerFunnelDashboard> createState() => _FarmerFunnelDashboardState();
}

class _FarmerFunnelDashboardState extends State<FarmerFunnelDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FarmerFunnelProvider>(context, listen: false)
          .fetchFarmerFunnel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoTranslateText('Farmer Funnel Dashboard'),
      ),
      body: Consumer<FarmerFunnelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: AutoTranslateText(provider.errorMessage!));
          }

          final funnelData = provider.farmerFunnel?.data ?? [];

          if (funnelData.isEmpty) {
            return const Center(child: AutoTranslateText("No farmers found."));
          }

          // ---- Group Farmers by Latest Entry Status ----
          final Map<String, List<FarmerFunnelData>> funnelMap = {};

          for (var farmer in funnelData) {
            String status = "Unknown";

            // Pick latest entry's status if exists
            if (farmer.entries != null && farmer.entries!.isNotEmpty) {
              status = farmer.entries!.last.status ?? "Unknown";
            }

            if (!funnelMap.containsKey(status)) {
              funnelMap[status] = [];
            }
            funnelMap[status]!.add(farmer);
          }

          final stages = funnelMap.keys.toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// ---- Funnel Summary ----
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: stages.map((stage) {
                      final count = funnelMap[stage]?.length ?? 0;
                      return Card(
                        color: Colors.blue.shade50,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: AutoTranslateText(
                            stage,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: AutoTranslateText(
                              count.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                /// ---- Detailed farmer list per stage ----
                ...stages.map((stage) {
                  final farmers = funnelMap[stage]!;
                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: AutoTranslateText(
                      '$stage (${farmers.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    children: farmers.map((farmer) {
                      return Card(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// --- Farmer Basic Info ---
                              AutoTranslateText(
                                farmer.farmerName ?? "",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              AutoTranslateText(
                                  'Mobile: ${farmer.mobileNumber ?? ""}'),

                              const SizedBox(height: 10),

                              /// --- Loop Entries → Crops → Products ---
                              if (farmer.entries != null &&
                                  farmer.entries!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AutoTranslateText(
                                      'Entries:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),

                                    ...farmer.entries!.map((entry) {
                                      return Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          AutoTranslateText(
                                              "Status: ${entry.status ?? 'N/A'}"),
                                          AutoTranslateText(
                                              "Date: ${entry.createdAt ?? ''}"),

                                          const SizedBox(height: 6),

                                          /// Crops inside entry
                                          if (entry.crops != null &&
                                              entry.crops!.isNotEmpty)
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const AutoTranslateText(
                                                  "Crops:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),

                                                ...entry.crops!.map((crop) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        AutoTranslateText(
                                                            "• Crop: ${crop.cropName ?? ''}"),

                                                        /// Products inside crop
                                                        if (crop.products !=
                                                            null &&
                                                            crop.products!
                                                                .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 12.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: crop
                                                                  .products!
                                                                  .map((p) =>
                                                                  AutoTranslateText(
                                                                      "- ${p.productName ?? ''}"))
                                                                  .toList(),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            ),

                                          const Divider(),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
