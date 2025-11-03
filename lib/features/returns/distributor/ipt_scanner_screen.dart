import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/add_return_scan_code_models.dart';
import 'package:TrustTags_DMS/data/models/ipt_add_order_model.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_add_order_provider.dart';
import 'package:TrustTags_DMS/features/returns/provider/ipt_scan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/qr_scanner_box.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../../common/app_colors.dart';

class IptScannerScreen extends StatefulWidget {
  final String toLocationId; // ✅ pass selected person’s id when navigating

  const IptScannerScreen({
    Key? key,
    required this.toLocationId,
  }) : super(key: key);

  @override
  State<IptScannerScreen> createState() => _IptScannerScreenState();
}

class _IptScannerScreenState extends State<IptScannerScreen> {
  final GlobalKey<ReusableQRScannerState> _scannerKey = GlobalKey();

  void _onQRCodeScanned(String code) async {
    final provider = Provider.of<IPTScanProvider>(context, listen: false);

    // ✅ Check if code already scanned
    bool alreadyScanned = provider.scannedItems.any((item) => item.uniqueCode == code);
    if (alreadyScanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ This code has already been scanned")),
      );
      _scannerKey.currentState?.resetScanner();
      return;
    }

    final id = await SharedPrefsHelper.getUserId();

    await provider.scanIPTCode(
      AddReturnScanCodePostData(uniqueCode: code, id: id ?? ""),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _scannerKey.currentState?.resetScanner();
    });
  }


  Future<void> _onSubmitOrder() async {
    final scanProvider = Provider.of<IPTScanProvider>(context, listen: false);
    final orderProvider =
    Provider.of<AddIPTOrderProvider>(context, listen: false);

    final fromLocation = await SharedPrefsHelper.getUserId();
    final toLocation = widget.toLocationId;

    if (fromLocation == null || toLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Missing from/to location")),
      );
      return;
    }

    if (scanProvider.scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please scan at least 1 item")),
      );
      return;
    }

    // ✅ Convert scanned items into LineItem list
    final lineItems = scanProvider.scannedItems.map((data) {
      return IPTLineItem(
        itemCode: data.product?.sku ?? "",        // use sku as itemCode
        qty: 1,                                   // per scan
        level: data.level ?? "", // from Data.level (string → int)
        batchId: data.productBatch?.id ?? "",
        price: double.tryParse(data.productBatch?.mrp ?? "0") ?? 0.0,
        reason: null,
        uniqueCode: data.uniqueCode ?? "",
        storagebinId: data.storageBinId?.toString() ?? "",

      );
    }).toList();

    final req = AddIPTOrderRequest(
      fromLocation: fromLocation,
      toLocation: toLocation,
      lineItems: lineItems,
    );

    await orderProvider.addIptOrder(req);

    if (orderProvider.response != null && orderProvider.response!.success == 1) {
      scanProvider.clear(); // ✅ clear list after successful order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Order Created: ${orderProvider.response!.orderId}")),
      );
      Navigator.of(context).pop(true); // return success
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${orderProvider.errorMessage ?? 'Order failed'}")),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    final scanProvider = Provider.of<IPTScanProvider>(context, listen: false);
    scanProvider.clear(); // Clear previous scans whenever screen is opened
  }




  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<IPTScanProvider>(context);
    final orderProvider = Provider.of<AddIPTOrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: Column(
        children: [
          const AppStatusBar(),

          // Top Bar
          Material(
            elevation: 2,
            child: Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "IPT Scan Screen",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanner + Items
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ReusableQRScanner(
                    key: _scannerKey,
                    onScanned: _onQRCodeScanned,
                  ),
                ),

                if (scanProvider.isLoading || orderProvider.isLoading)
                  const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (scanProvider.errorMessage != null)
                  SizedBox(
                    height: 60,
                    child: Center(
                      child: Text(
                        scanProvider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (scanProvider.scannedItems.isNotEmpty)
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: scanProvider.scannedItems.length,
                        itemBuilder: (context, index) {
                          final data = scanProvider.scannedItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.qr_code),
                              title:
                              Text(data.product?.name ?? 'Unknown Product'),
                              subtitle: Text(
                                'MRP: ₹${data.productBatch?.mrp ?? 'N/A'}',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),

          // ✅ Submit Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: orderProvider.isLoading ? null : _onSubmitOrder, // optional icon
                label: const Text(
                  "Add IPT Order",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppColors.topBarColor, // <-- set your desired color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // optional rounded corners
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
