import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:TrustTags_DMS/common/widgets/qr_scanner_box.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/data/models/inward_preview_model.dart';
import 'package:TrustTags_DMS/features/dashboard/helper/scan_screen_details.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/inward_provider.dart';

class InwardScreen extends StatefulWidget {
  const InwardScreen({super.key});

  @override
  State<InwardScreen> createState() => _InwardScreenState();
}

class _InwardScreenState extends State<InwardScreen> {
  String scannedUID = '';
  final TextEditingController _uidController = TextEditingController();
  int _scannerKeyCounter = 0; // unique key counter for the scanner
  GlobalKey<ReusableQRScannerState> scannerKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  Future<void> _fetchAndNavigate(String uid) async {
    final inwardProvider = Provider.of<InwardProvider>(context, listen: false);
    try {
      scannerKey.currentState?.forceDisposeCamera();
    } catch (_) {}

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await inwardProvider.fetchInwardDetails(uid);

    Navigator.of(context).pop(); // Close loading dialog

    if (inwardProvider.inwardPreview != null &&
        inwardProvider.inwardPreview!.success == 1 &&
        inwardProvider.inwardPreview!.data != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanDetailsScreen(
            orderDetails: inwardProvider.inwardPreview!.data!,
          ),
        ),
      );

      // Reset scanner and text field when coming back
      setState(() {
        scannedUID = '';
        _uidController.clear();
        scannerKey = GlobalKey<ReusableQRScannerState>(); // force rebuild of scanner to restart camera
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(inwardProvider.error ?? "Something went wrong")),
      );
    }
  }

  void handleScan(String uid) {
    if (scannedUID != uid) {
      setState(() => scannedUID = uid);
      _fetchAndNavigate(uid);
    }
  }

  void handleManualEntry() {
    final enteredUID = _uidController.text.trim();
    if (enteredUID.length == 36) {
      _fetchAndNavigate(enteredUID);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("Please enter a valid 36-digit UID"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Column(
        children: [
          const AppStatusBar(),

          // Top Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AutoTranslateText(
                  'Scan QR',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Image.asset(
                  'assets/images/trust_tags.png',
                  height: 40,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // QR Scanner
                  ReusableQRScanner(
                    key: scannerKey,    // ✅ use new key
                    onScanned: handleScan,
                  ),


                  const SizedBox(height: 20),

                  // Manual Entry
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _uidController,
                              keyboardType: TextInputType.name,
                              maxLength: 48,
                              decoration: const InputDecoration(
                                hintText: 'Enter UID manually',
                                border: InputBorder.none,
                                counterText: '',
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: handleManualEntry,
                            child: CircleAvatar(
                              backgroundColor: AppColors.primaryPurple,
                              radius: 18,
                              child: const Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AutoTranslateText(
                        'SCAN DETAILS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: AutoTranslateText(
                        scannedUID.isNotEmpty ? 'Scanned UID: $scannedUID' : 'No scan yet.',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
