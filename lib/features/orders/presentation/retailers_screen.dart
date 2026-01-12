import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/core/permissions/feature_mapper.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/dist_retailer_list_for_rout_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/tsi_retailer_registration.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:TrustTags_DMS/features/orders/presentation/received_order_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:TrustTags_DMS/data/models/dist_retailer_rout_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RetailersScreen extends StatefulWidget {
  final String? tsiId;
  const RetailersScreen({super.key,this.tsiId});

  @override
  State<RetailersScreen> createState() => _RetailersScreenState();
}

class _RetailersScreenState extends State<RetailersScreen> {
  @override
  void initState() {
    super.initState();
    // Use microtask to avoid calling provider before the widget tree is ready
    Future.microtask(() => _initRetailersProvider());
  }
  Future<void> _initRetailersProvider() async {
    final provider = legacy.Provider.of<TerritoryProvider>(context, listen: false);
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    if (userId != null && userId.isNotEmpty) {
      if (roleId == 19 && widget.tsiId != null && widget.tsiId!.isNotEmpty) {
        // Fetch retailers for specific TSI
        await provider.fetchRetailers(widget.tsiId!);
      } else {
        // Fetch retailers for current user
        await provider.fetchRetailers(userId);
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
            shadowColor: Colors.black,
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
                      'Retailers Orders',
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
            child: legacy.Consumer<TerritoryProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(child: AutoTranslateText(provider.errorMessage!));
                }

                final List<TerritoryData> data = provider.retailers;

                if (data.isEmpty) {
                  return const Center(child: AutoTranslateText("No retailers found."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final phone = item.phone ?? "";

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
                                  distributorId: item.id ?? '',
                                  roleId: 3, // Retailer role
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // All padded content
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Retailer Name + Action Icons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: AutoTranslateText(
                                            item.name ?? 'Unknown Retailer',
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
                                              icon: const Icon(
                                                  FontAwesomeIcons.whatsapp,
                                                  color: Colors.green),
                                              onPressed: () => _openWhatsApp(phone),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.call,
                                                  color: Colors.deepPurple),
                                              onPressed: () => _makeCall(phone),
                                            ),
                                            IconButton(
                                              onPressed: () => _initRetailersProvider(),
                                              icon: const Icon(Icons.refresh),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),


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
                                          "P: ${item.pending ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          "C: ${item.accepted ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.green,
                                          ),
                                        ),
                                        AutoTranslateText(
                                          "R: ${item.rejected ?? 0}",
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

      // Floating Action Button
      floatingActionButton: Consumer(
        builder: (context, ref, _) {
          final permissionState = ref.watch(permissionsProvider);

          final canRegisterRetailer =
              permissionState.data != null &&
                  permissionState.data!.data.any(
                        (f) =>
                    FeatureMapper.fromId(f.featureId) ==
                        FeatureAccess.registerRetailer &&
                        f.permissions.create == true,
                  );

          if (!canRegisterRetailer) {
            return const SizedBox.shrink(); // ❌ hide FAB
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TsiRetailerRegistration(),
                  ),
                );
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
