import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_return_claim_models.dart';
import 'package:TrustTags_DMS/data/models/add_return_scan_code_models.dart';
import 'package:TrustTags_DMS/features/returns/provider/add_return_order_claim_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/scan_return_order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/app_colors.dart';
import '../../common/widgets/app_status_bar.dart';
import '../../common/widgets/qr_scanner_box.dart';

class AddReturnOrderScreen extends StatefulWidget {
  final String? distributorName;
  final String? distributorId;

  const AddReturnOrderScreen({
    Key? key,
    this.distributorName,
    this.distributorId,
  }) : super(key: key);

  @override
  State<AddReturnOrderScreen> createState() => _AddReturnOrderScreenState();
}

class _AddReturnOrderScreenState extends State<AddReturnOrderScreen> {
  /// Store all scanned products
  List<ScannedItem> scannedItems = [];

  /// Whether scanning is currently active
  bool _scannerActive = true;

  /// Prevent duplicate scans
  bool _isProcessingScan = false;

  /// Handle scan event
  void handleScan(String value) async {
    if (_isProcessingScan || !_scannerActive) return;
    _isProcessingScan = true;
    setState(() => _scannerActive = false); // stop scanner immediately
    final id=await SharedPrefsHelper.getUserId();

    final provider = context.read<ReturnOrderProvider>();
    await provider.addScanReturnClaim(value,id??"");
    final scanData = provider.scanResponse?.data;

    if (scanData != null) {
      // ✅ Check if QR already exists
      final alreadyExists = scannedItems.any(
            (item) => item.response.data?.uniqueCode == scanData.uniqueCode,
      );

      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ This QR has already been scanned.")),
        );
      } else {
        String? selectedReason = await showReasonDialog();

        if (selectedReason != null) {
          setState(() {
            scannedItems.add(
              ScannedItem(
                response: provider.scanResponse!,
                reason: selectedReason,
              ),
            );
          });
        }
      }
    } else {
      final errorMessage = provider.scanResponse?.message ?? "Invalid QR code.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    // Restart scanner safely after short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _scannerActive = true;
        });
      }
      _isProcessingScan = false;
    });
  }

  /// Dialog to select reason after scan
  Future<String?> showReasonDialog() async {
    String? selectedReason;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Reason"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButtonFormField<String>(
                items: ["Damaged", "Expired", "Wrong Product", "Other"]
                    .map((reason) => DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                ))
                    .toList(),
                onChanged: (value) {
                  setDialogState(() => selectedReason = value);
                },
                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedReason != null) {
                  Navigator.pop(context, selectedReason);
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Consumer2<ReturnOrderProvider, AddReturnClaimProvider>(
        builder: (context, scanProvider, claimProvider, child) {
          return Column(
            children: [
              const AppStatusBar(),

              // AppBar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    top: 18, left: 12, right: 12, bottom: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Add Return Order',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),

              // const SizedBox(height: 8),

              // Distributor Info
              if (widget.distributorName != null &&
                  widget.distributorName!.trim().isNotEmpty)

              const SizedBox(height: 8),

              // ✅ QR Scanner with fixed height (no overflow now)
              SizedBox(
                height: 500,
                width: double.infinity,
                child: _scannerActive
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ReusableQRScanner(
                    key: ValueKey("scanner_${scannedItems.length}"),
                    onScanned: handleScan,
                  ),
                )
                    : const Center(
                  child: Text(
                    "Processing scan...",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Scanned items list (takes remaining space)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: scannedItems.length,
                  itemBuilder: (context, index) {
                    final item = scannedItems[index];
                    return buildScannedItemCard(item);
                  },
                ),
              ),

              // Submit Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(

                    onPressed: scannedItems.isNotEmpty && !claimProvider.isLoading
                        ? () async {
                      final createdBy = await SharedPrefsHelper.getUserId();
                      final roleId = await SharedPrefsHelper.getRoleId();


                      String? fromLocation;
                      if (roleId == 18) {
                        fromLocation = await SharedPrefsHelper.getDailylocationId();
                      } else {
                        fromLocation = createdBy;
                      }

                      // ✅ Decide requestedRoleId (same as your current logic)
                      String? requestedRoleId;
                      if (roleId == 18) {
                        requestedRoleId = roleId?.toString();
                      } else {
                        requestedRoleId = roleId?.toString();
                      }

                      final toLocation = widget.distributorId;

                      final lineItems = scannedItems.map((item) {
                        final scanData = item.response.data!;
                        return LineItems(
                          itemCode: scanData.product?.sku ?? "",
                          qty: "1",
                          level: scanData.level ?? "",
                          batchId: scanData.batchId ?? "",
                          price: scanData.productBatch?.mrp ?? "0",
                          reason: item.reason ?? "",
                          uniqueCode: scanData.uniqueCode ?? "",
                        );
                      }).toList();

                      // ✅ Check if roleId = 18, then getDailyRoleId
                      int finalRoleId = roleId ?? 0;
                      if (roleId == 18) {
                        final dailyRoleId = await SharedPrefsHelper.getDailyRoleId();
                        finalRoleId = int.tryParse(dailyRoleId ?? "0") ?? 0;
                      }
                      debugPrint("👉 roleId: $roleId | finalRoleId: $finalRoleId");


                      final requestData = AddReturnClaimPostData(
                        price: scannedItems
                            .map((e) =>
                        double.tryParse(e.response.data?.productBatch?.mrp ?? "0") ??
                            0)
                            .fold(0.0, (a, b) => a + b)
                            .toString(),
                        roleId: finalRoleId, // ✅ use updated roleId here
                        requestedRoleId: int.tryParse(requestedRoleId ?? "0") ?? 0,
                        qty: scannedItems.length,
                        createdBy: createdBy ?? "",
                        fromLocation: fromLocation ?? "",
                        toLocation: toLocation ?? "",
                        lineItems: lineItems,
                      );


                      await claimProvider.addReturnClaim(requestData);

                      if (claimProvider.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${claimProvider.errorMessage}")),
                        );
                      } else if (claimProvider.response != null) {
                        debugPrint(
                            "👉 Created Return OrderId: ${claimProvider.response!.orderId}");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "✅ Return Order Submitted. OrderId: ${claimProvider.response!.orderId}",
                            ),
                          ),
                        );

                        Navigator.pop(context, claimProvider.response?.orderId);
                      }
                    }
                        : null,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: claimProvider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Complete",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildScannedItemCard(ScannedItem item) {
    final data = item.response.data;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product: ${data?.product?.name ?? '-'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "Price: ${data?.productBatch?.mrp ?? '-'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("Reason: ${item.reason ?? '-'}"),
        ],
      ),
    );
  }
}

class ScannedItem {
  final AddReturnScanCodeResponse response;
  String? reason;

  ScannedItem({required this.response, this.reason});
}
