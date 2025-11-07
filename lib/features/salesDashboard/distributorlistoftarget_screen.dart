import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tabs/achieved_card.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tabs/target_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class DistributorListScreen extends StatefulWidget {
  final String? tsiId;

  const DistributorListScreen({super.key, this.tsiId});

  @override
  State<DistributorListScreen> createState() => _DistributorListScreenState();
}

class _DistributorListScreenState extends State<DistributorListScreen> {
  @override
  void initState() {
    super.initState();
    _loadDistributors();
  }

  Future<void> _loadDistributors() async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    String? finalId = (roleId == 19 && widget.tsiId != null && widget.tsiId!.isNotEmpty)
        ? widget.tsiId
        : userId;

    if (finalId != null && finalId.isNotEmpty) {
      await Provider.of<TerritoryProvider>(context, listen: false)
          .fetchDistributors(finalId);
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

  void _navigateToTargetOrSales(String distributorId) async {
    final roleId = await SharedPrefsHelper.getRoleId();

    // ✅ For roleId 19, behave same as roleId 18 → directly show Target/Sales sheet
    if (roleId == 19 || roleId == 18) {
      _showTargetSalesOptions(null, distributorId);
    } else {
      // Other roles → directly show Target/Sales options too
      _showTargetSalesOptions(null, distributorId);
    }
  }

  void _showTargetSalesOptions(String? tsiId, String distributorId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const AutoTranslateText("View Target"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductListingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const AutoTranslateText("View Sales"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AchievedTargetListingScreen(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
                      'Distributors',
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
                    final dist = distributors[index];
                    final phone = dist.phone ?? "";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _navigateToTargetOrSales(dist.id!),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            child: Row(
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
                                  ],
                                ),
                              ],
                            ),
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
