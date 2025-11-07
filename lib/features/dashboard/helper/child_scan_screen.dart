import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/common/widgets/qr_scanner_box.dart';
import 'package:TrustTags_DMS/data/models/scan_child_code_model.dart';
import 'package:TrustTags_DMS/features/scan/providers/child_code_delete_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/child_code_scan_provider.dart';
import 'package:TrustTags_DMS/features/scan/providers/inward_complete_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InvoiceQRScannerScreen extends StatefulWidget {
  final String orderId;
  const InvoiceQRScannerScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<InvoiceQRScannerScreen> createState() => _InvoiceQRScannerScreenState();
}

class _InvoiceQRScannerScreenState extends State<InvoiceQRScannerScreen> with WidgetsBindingObserver {
  final TextEditingController _manualUidController = TextEditingController();
  String _activeTab = "scan"; // scan | delete | addLoose
  bool _scannerInitialized = false;
  bool is_processing = false;

  // **Local list to keep scanned items**
  List<dynamic> scannedItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // RESET providers so screen is fresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChildCodeScanProvider>().reset();
        context.read<DeleteScanProvider>().reset();
        context.read<SubmitScanProvider>().reset();

        _scannerInitialized = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed && !_scannerInitialized) {
      setState(() {
        _scannerInitialized = true;
      });
    }
  }

  void _resetScanner() {
    _manualUidController.clear();
    setState(() => _scannerInitialized = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scannerInitialized = true;
      setState(() {});
    });
  }

  Future<void> _callScanApi(String uid, {bool addLoose = false}) async {
    final provider = context.read<ChildCodeScanProvider>();
    await provider.scanCode(
      ScanInfoPostData(orderId: widget.orderId, addLoose: addLoose, uniqueCode: uid),
    );
  }

  Future<void> _callDeleteApi(String uid) async {
    final deleteProvider = context.read<DeleteScanProvider>();
    await deleteProvider.deleteScanCode(orderId: widget.orderId, uniqueCode: uid);
  }

  void _onScanned(String value) async {
    if (is_processing) return;
    is_processing = true;
    try {
      if (_activeTab == "delete") {
        await _callDeleteApi(value);

        // Remove deleted item from local list
        scannedItems.removeWhere((item) => item.uniqueCode == value);
      } else {
        await _callScanApi(value, addLoose: _activeTab == "addLoose");

        // Add scanned item to local list
        final provider = context.read<ChildCodeScanProvider>();
        if (provider.scanResponse?.data != null) {
          scannedItems.add(provider.scanResponse!.data);
        }
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      is_processing = false;
      _resetScanner();
      setState(() {}); // rebuild UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<ChildCodeScanProvider, DeleteScanProvider>(
        builder: (context, scanProvider, deleteProvider, child) {
          return Column(
            children: [
              const AppStatusBar(),
              Material(
                elevation: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AutoTranslateText(
                        "Scan QR",
                        style: TextStyle(
                            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Image.asset("assets/images/trust_tags.png", height: 38),
                    ],
                  ),
                ),
              ),
              if (_scannerInitialized)
                ReusableQRScanner(onScanned: (value) => _onScanned(value))
              else
                Container(
                  height: 250,
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: TextField(
                  controller: _manualUidController,
                  decoration: InputDecoration(
                    hintText: "Enter UID manually",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_circle_right, color: Colors.purple),
                      onPressed: () {
                        if (_manualUidController.text.isNotEmpty) {
                          _onScanned(_manualUidController.text);
                        }
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton("Delete", "delete", Colors.redAccent),
                  _buildTabButton("Scan", "scan", Colors.green),
                  _buildTabButton("Add/Loose", "addLoose", Colors.blue),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    children: [
                      _buildResultBox(scanProvider, deleteProvider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String label, String value, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _activeTab == value ? color : color.withOpacity(0.3),
      ),
      onPressed: () {
        setState(() => _activeTab = value);
        _resetScanner();
      },
      child: AutoTranslateText(label,
          style: TextStyle(
              color: _activeTab == value ? Colors.white : Colors.black54)),
    );
  }

  Widget _buildResultBox(
      ChildCodeScanProvider scanProvider, DeleteScanProvider deleteProvider) {

    final error = _activeTab == "delete" ? deleteProvider.errorMessage : scanProvider.errorMessage;
    final message = _activeTab == "delete" ? deleteProvider.deleteResponse?.message : scanProvider.scanResponse?.message;

    List<Widget> items = [];

    if (error != null) items.add(_buildMessageBox(error, Colors.red.shade100, Colors.red));
    if (message != null) items.add(_buildMessageBox(message, Colors.green.shade100, Colors.green));

    if (scannedItems.isNotEmpty) {
      items.add(const SizedBox(height: 10));
      items.addAll(scannedItems.map((data) => _buildDataCard(data)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildMessageBox(String text, Color bgColor, Color borderColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 1.2)),
      child: AutoTranslateText(text,
          style: TextStyle(color: borderColor, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDataCard(dynamic data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow("UID", data.uniqueCode ?? ""),
            _buildRow("Item Code", data.sku ?? ""),
            _buildRow("Batch", data.batchNo ?? ""),
            _buildRow("Order Qty", data.orderQty ?? ""),
            _buildRow("QTY", data.qty ?? ""),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoTranslateText(label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          AutoTranslateText(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
