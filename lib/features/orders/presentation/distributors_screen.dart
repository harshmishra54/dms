import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/network/dio_client.dart';
import 'package:TrustTags_DMS/data/models/dist_stock_models.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/credit_limit_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/all_focus_new_product_stock_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/stock_data_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/stock_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/dist_retailer_rout_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tsi_distributor_registration.dart';
import '../../orders/presentation/received_order_list_screen.dart';

class DistributorsScreen extends StatefulWidget {
  final String? tsiId;

  const DistributorsScreen({super.key, this.tsiId});

  @override
  State<DistributorsScreen> createState() => _DistributorsScreenState();
}

class _DistributorsScreenState extends State<DistributorsScreen> {
  @override
  void initState() {
    super.initState();
    _loadDistributors(); // triggers everything after distributors are loaded
  }

  Future<void> _loadDistributors() async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    String? finalId;
    if (roleId == 19 && widget.tsiId != null && widget.tsiId!.isNotEmpty) {
      finalId = widget.tsiId;
    } else {
      finalId = userId;
    }

    if (finalId != null && finalId.isNotEmpty) {
      // Fetch distributors first
      await Provider.of<TerritoryProvider>(context, listen: false)
          .fetchDistributors(finalId);

      // ✅ Now distributors are available
      final distributors = Provider.of<TerritoryProvider>(context, listen: false).distributors;
      final stockProvider = Provider.of<AllFocusNewProductStockProvider>(context, listen: false);
      final creditProvider = Provider.of<CreditLimitProvider>(context, listen: false);

      for (var dist in distributors) {
        // Trigger APIs here
        stockProvider.fetchFocusProductStock(dist.id ?? '');
        creditProvider.fetchDistributorCreditLimit(
          roleId: "1",
          distributorId: dist.id ?? "",
          forceRefresh: true,
        );
      }
    }
  }



  Future<void> _openWhatsApp(String phone) async {
    final Uri whatsapp = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri call = Uri.parse("tel:$phone");
    if (await canLaunchUrl(call)) {
      await launchUrl(call);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
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
                  const Expanded(
                    child: AutoTranslateText(
                      'Distributors Orders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
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
            child: Consumer<TerritoryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                }

                final distributors = provider.distributors;

                if (distributors.isEmpty) {
                  return const Center(child: AutoTranslateText('No distributors found.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: distributors.length,
                  itemBuilder: (context, index) {
                    final TerritoryData dist = distributors[index];
                    final phone = dist.phone ?? "";

                    // trigger credit fetch for this distributor
                    final creditProvider = Provider.of<CreditLimitProvider>(context);
                    final creditData = creditProvider.creditMap[dist.id];
                    final isLoadingCredit = creditProvider.loadingMap[dist.id] == true;

// Trigger API if not loading and not yet fetched

                    final double approved = double.tryParse(creditData?.approvedLimit ?? "0") ?? 0;
                    final double current = double.tryParse(creditData?.currentLimit ?? "0") ?? 0;
                    final ratio = (approved > 0) ? (current / approved).clamp(0.0, 1.0) : 0.0;
                    final percentage = (ratio * 100).toStringAsFixed(1); // 99.9%


                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceivedOrderListScreen(
                                  distributorId: dist.id ?? '',
                                  roleId: 1,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Distributor Name + Action Icons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: AutoTranslateText(
                                            dist.name ?? 'Unknown Distributor',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                                              onPressed: () => _openWhatsApp(phone),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.call, color: Colors.deepPurple),
                                              onPressed: () => _makeCall(phone),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _loadDistributors();
                                                });
                                              },
                                              icon: const Icon(Icons.refresh),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Target Progress (still static for now)
                                    Row(
                                      children: [
                                        const AutoTranslateText("Target Progress", style: TextStyle(fontSize: 12)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: LinearProgressIndicator(
                                            value: 0.7,
                                            minHeight: 6,
                                            color: Colors.deepPurple,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const AutoTranslateText("70%"),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // Credit Limit (dynamic)
                                    Row(
                                      children: [
                                        const AutoTranslateText("Credit Limit", style: TextStyle(fontSize: 12)),
                                        const SizedBox(width: 30),
                                        Expanded(
                                          flex: 2,
                                          child: isLoadingCredit
                                              ? LinearProgressIndicator(
                                            value: null, // indeterminate loader
                                            minHeight: 6,
                                            backgroundColor: Colors.grey[300],
                                          )
                                              : LinearProgressIndicator(
                                            value: ratio.isNaN ? 0 : ratio,
                                            minHeight: 6,
                                            color: Colors.purpleAccent,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        AutoTranslateText(
                                          isLoadingCredit ? "--" : "$percentage%",
                                        ),
                                      ],
                                    ),



                                    const SizedBox(height: 8),

                                    // Order Status Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const AutoTranslateText(
                                          "Order:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          "P: ${dist.pending ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          "C: ${dist.accepted ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          "R: ${dist.rejected ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Inventory container
                        // Inventory container with dynamic stock values
                        Consumer<AllFocusNewProductStockProvider>(
                          builder: (context, stockProvider, _) {
                            final stock = stockProvider.stockMap[dist.id];
                            final isLoading = stockProvider.isLoadingMap[dist.id] ?? false;
                            final error = stockProvider.errorMap[dist.id];



                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChangeNotifierProvider(
                                      create: (_) => DistStockProvider(dioClient: DioClient())
                                        ..fetchDistStock(
                                          request: DistStockRequest(
                                            exportType: "1",
                                            locationId: dist.id,
                                          ),
                                        ),
                                      child: StockDetailsScreen(
                                        title: dist.name ?? "Stock Details",
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const AutoTranslateText(
                                      "Inventory",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.inventory, color: Colors.brown, size: 20),
                                            SizedBox(width: 4),
                                            AutoTranslateText("Focused", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        AutoTranslateText(isLoading ? "--" : "${stock?.F ?? 0}", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.local_florist, color: Colors.teal, size: 20),
                                            SizedBox(width: 4),
                                            AutoTranslateText("Seasonal", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        AutoTranslateText(isLoading ? "--" : "${stock?.B ?? 0}", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.star, color: Colors.amber, size: 20),
                                            SizedBox(width: 4),
                                            AutoTranslateText("Scheme", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        AutoTranslateText(isLoading ? "--" : "${stock?.S ?? 0}", style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 25),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TsiDistributorRegistration(),
                ),
              );
            },
            backgroundColor: AppColors.topBarColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
