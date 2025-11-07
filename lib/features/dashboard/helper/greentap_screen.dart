import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/scan/providers/child_code_delete_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/inward_scan_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/inward_scan_details_model.dart';

class GreenTapScreen extends StatefulWidget {
  final String orderId;
  final String orderDetailsId;
  final int type; // 1 = green, 2 = red

  const GreenTapScreen({
    super.key,
    required this.orderId,
    required this.orderDetailsId,
    required this.type,
  });

  @override
  State<GreenTapScreen> createState() => _GreenTapScreenState();
}

class _GreenTapScreenState extends State<GreenTapScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch scan details on load
    Future.microtask(() {
      Provider.of<InwardScanProvider>(context, listen: false)
          .fetchInwardScanDetails(
        InwardScanDetails(
          orderId: widget.orderId,
          orderDetailsId: widget.orderDetailsId,
          type: widget.type,
        ),
      );
    });
  }

  /// Delete confirmation + API call + UI update
  Future<void> _confirmDelete(BuildContext context, String uniqueCode) async {
    final deleteProvider = Provider.of<DeleteScanProvider>(context, listen: false);
    final scanProvider = Provider.of<InwardScanProvider>(context, listen: false);

    // Save ScaffoldMessenger before any await
    final messenger = ScaffoldMessenger.of(context);

    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const AutoTranslateText("Confirm Delete"),
        content: AutoTranslateText("Are you sure you want to delete $uniqueCode?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const AutoTranslateText("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const AutoTranslateText(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Call delete API
    await deleteProvider.deleteScanCode(
      orderId: widget.orderId,
      uniqueCode: uniqueCode,
    );

    if (!mounted) return;

    // Show error or success SnackBar
    if (deleteProvider.errorMessage != null) {
      messenger.showSnackBar(
        SnackBar(content: AutoTranslateText(deleteProvider.errorMessage!)),
      );
    } else {
      // Optimistic UI update: remove locally
      scanProvider.scanData?.list?.removeWhere((e) => e.uniqueCode == uniqueCode);
      scanProvider.notifyListeners();

      messenger.showSnackBar(
        SnackBar(content: AutoTranslateText("Deleted $uniqueCode")),
      );

      // Optional: refresh from server for consistency
      await scanProvider.fetchInwardScanDetails(
        InwardScanDetails(
          orderId: widget.orderId,
          orderDetailsId: widget.orderDetailsId,
          type: widget.type,
        ),
      );
    }
  }

  /// Pull-to-refresh
  Future<void> _refreshList(BuildContext context) async {
    final scanProvider = Provider.of<InwardScanProvider>(context, listen: false);
    scanProvider.clearData();
    await scanProvider.fetchInwardScanDetails(
      InwardScanDetails(
        orderId: widget.orderId,
        orderDetailsId: widget.orderDetailsId,
        type: widget.type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<InwardScanProvider>(context);
    final deleteProvider = Provider.of<DeleteScanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const AppStatusBar(),

          // Top bar
          Material(
            elevation: 4,
            shadowColor: Colors.black26,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
                  const Expanded(
                    child: Center(
                      child: AutoTranslateText(
                        'Scan Details',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/images/trust_tags.png',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refreshList(context),
              child: scanProvider.isLoading || deleteProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : scanProvider.errorMessage != null
                  ? Center(child: AutoTranslateText(scanProvider.errorMessage!))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: scanProvider.scanData?.list?.length ?? 0,
                itemBuilder: (context, index) {
                  final item = scanProvider.scanData!.list![index];

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: Colors.grey.shade300, width: 0.5),
                    ),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // UID text
                          Expanded(
                            child: AutoTranslateText(
                              item.uniqueCode,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),

                          // Delete icon only for type 1
                          if (widget.type == 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDelete(context, item.uniqueCode),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
