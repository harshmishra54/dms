import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/spinner/presentation/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/qr_scanner_box.dart';
import '../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../scan/providers/scan_provider.dart';
import '../../scan/models/scan_post_data.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  String scannedUID = '';
  bool _isLoading = false; // ✅ loader flag
  bool _isDialogOpen = false;

  final TextEditingController _manualController = TextEditingController();

  final GlobalKey<State<ReusableQRScanner>> _scannerKey =
  GlobalKey<State<ReusableQRScanner>>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _showScanResultDialog({
    required bool isValid,
    required String productName,
    required String productUID,
    required String points,
    required String message,
  }) {
    final color = isValid ? Colors.green : Colors.redAccent;
    final title = isValid ? "Valid Scan" : "Invalid Scan";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoTranslateText(title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 12),
                Icon(Icons.qr_code_2, color: color, size: 40),
                const SizedBox(height: 20),
                _buildReadOnlyField("Points", points),
                const SizedBox(height: 15),
                _buildReadOnlyField("Product Name", productName),
                const SizedBox(height: 15),
                _buildReadOnlyField("Product UID", productUID),
                const SizedBox(height: 15),
                _buildReadOnlyField("Message", message),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _isDialogOpen = false; // ▶️ allow scanning again
                      (_scannerKey.currentState as dynamic).resetScanner();
                    },

                    child: const AutoTranslateText(
                      'Okay',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoTranslateText(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            hintText: value,
          ),
        ),
      ],
    );
  }

  Future<void> _handleScan(BuildContext context, String uid) async {
    if (_isDialogOpen) return; // ⛔ BLOCK repeated scans

    _isDialogOpen = true;
    setState(() {
      scannedUID = uid;
      _isLoading = true; // ✅ show loader
    });

    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final token = await SharedPrefsHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      _showScanResultDialog(
        isValid: false,
        productName: "Token Missing",
        productUID: uid,
        points: "0",
        message: "Authentication token missing",
      );
      return;
    }

    final postData = ScanPostData(isQrCodeDetected: true, uniqueCode: uid);
    final validateRes = await scanProvider.validateUID(token, postData);

    setState(() => _isLoading = false); // ✅ hide loader

    // ✅ Extract spinnerId safely (data is String)
    String? spinnerId = validateRes.data is String
        ? validateRes.data as String
        : null;

// ✅ If segments exist → Open Spinner
    if (spinnerId != null && validateRes.segments != null &&
        validateRes.segments!.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SpinnerWidget(
                spinnerId: spinnerId,
                segments: validateRes.segments!,
              ),
        ),
      );

      (_scannerKey.currentState as dynamic).resetScanner();
      return;
    }


// ✅ OLD behavior stays same
    if (validateRes.success == 1 && validateRes.data != null) {
      String productName = "Unknown Product";
      String productUID = uid;
      String points = "0";
      String message = validateRes.message.isNotEmpty
          ? validateRes.message
          : "Scan successful";

      // ✅ If data is object (Map) then convert to SchemeData
      if (validateRes.data is Map<String, dynamic>) {
        final scheme = SchemeData.fromJson(validateRes.data);

        productName = scheme.productName ?? "Unknown Product";
        productUID = scheme.schemeUID ?? uid;
        points = scheme.points?.toString() ?? "0";
        message = scheme.message ?? validateRes.message;
      }

      _showScanResultDialog(
        isValid: true,
        productName: productName,
        productUID: productUID,
        points: points,
        message: message,
      );
    } else {
      String productUID = "";

      if (validateRes.data is Map<String, dynamic>) {
        final scheme = SchemeData.fromJson(validateRes.data);
        productUID = scheme.schemeUID ?? "";
      }

      _showScanResultDialog(
        isValid: false,
        productName: "Not Valid",
        productUID: productUID,
        points: "0",
        message: validateRes.message.isNotEmpty
            ? validateRes.message
            : "Invalid QR code",
      );
    }

    (_scannerKey.currentState as dynamic).resetScanner();
  }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          Column(
            children: [
              const AppStatusBar(),
              Container(
                color: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AutoTranslateText(
                      'Scan QR',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w600),
                    ),
                    Image.asset('assets/images/trust_tags.png', height: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ReusableQRScanner(
                        key: _scannerKey,
                        onScanned: (uid) => _handleScan(context, uid),
                      ),
                      const SizedBox(height: 20),
                      _buildManualEntry(),
                      const SizedBox(height: 24),
                      _buildScanDetails(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ✅ Loader overlay
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    return Padding(
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
                controller: _manualController,
                decoration: const InputDecoration(
                  hintText: 'Enter UID manually',
                  border: InputBorder.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                final enteredUID = _manualController.text.trim();
                if (enteredUID.isNotEmpty) {
                  _handleScan(context, enteredUID);
                  _manualController.clear();
                }
              },
              child: CircleAvatar(
                backgroundColor: AppColors.primaryPurple,
                radius: 18,
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanDetails() {
    return Column(
      children: [
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
              scannedUID.isNotEmpty
                  ? 'Scanned UID: $scannedUID'
                  : 'No scan yet.',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
