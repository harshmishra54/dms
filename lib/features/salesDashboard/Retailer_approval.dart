import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/update_retailer_registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/retailer_rsm_approval_provider.dart';

class RetailerApprovalScren extends StatefulWidget {
  const RetailerApprovalScren({super.key});

  @override
  State<RetailerApprovalScren> createState() => _RetailerApprovalScrenState();
}

class _RetailerApprovalScrenState extends State<RetailerApprovalScren> {
  // Track loading per retailer ID to show button loader
  final Map<String, bool> _buttonLoading = {};
  String? _userId;


  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await SharedPrefsHelper.getUserId();
    setState(() {
      _userId = userId;
    });

    // 👇 trigger API once userId is available
    if (userId != null) {
      Future.microtask(() {
        Provider.of<RetailRsmProvider>(context, listen: false)
            .fetchRetailRsm(userId);
      });
    }
  }

  // Handle approve/reject
  Future<void> _handleStatusChange(String retailerId, bool status) async {
    setState(() {
      _buttonLoading[retailerId] = true;
    });

    final provider = Provider.of<UpdateRetailerRsmProvider>(context, listen: false);
    final success = await provider.updateRetailerStatus(id: retailerId, status: status);

    setState(() {
      _buttonLoading[retailerId] = false;
    });

    if (success) {
      // Show success message
      if (provider.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText(provider.message!)),
        );
      }

      // Refresh the list after status update
      await Provider.of<RetailRsmProvider>(context, listen: false).fetchRetailRsm(_userId??"");
    } else {
      if (provider.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoTranslateText(provider.message!)),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// Custom Status Bar
          const AppStatusBar(),

          /// AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const AutoTranslateText(
                  "Registered Retailers",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),

          /// Retailer List
          Expanded(
            child: Consumer<RetailRsmProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: AutoTranslateText(
                      provider.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (provider.rsmList.isEmpty) {
                  return const Center(child: AutoTranslateText("No Retailers found"));
                }

                return ListView.builder(
                  itemCount: provider.rsmList.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final distributor = provider.rsmList[index];
                    final isLoading = _buttonLoading[distributor.id] ?? false;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Avatar + Name + Address
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: AutoTranslateText(
                                    (distributor.name?.isNotEmpty == true
                                        ? distributor.name![0]
                                        : "-")
                                        .toUpperCase(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoTranslateText(
                                        distributor.name ?? "-",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AutoTranslateText(
                                        distributor.firmName ?? "No address",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Bottom Row: Approve / Reject Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleStatusChange(distributor.id!, true),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.purple, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // circular pill shape
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const AutoTranslateText("Approve",style: TextStyle(color: Colors.purple),),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _handleStatusChange(distributor.id!, false),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.purple, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20), // circular pill shape
                                    ),
                                    minimumSize: const Size(80, 36),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const AutoTranslateText("Reject",style: TextStyle(color: Colors.purple),),
                                ),
                              ],
                            ),
                          ],
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
