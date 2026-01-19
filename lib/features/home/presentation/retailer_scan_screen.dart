import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/asynchronous_reward_response_model.dart';
import 'package:TrustTags_DMS/features/home/presentation/history_screen.dart';
import 'package:TrustTags_DMS/features/home/widgets/history_points_section.dart';
import 'package:TrustTags_DMS/features/scan/models/product_level_check_model.dart';
import 'package:TrustTags_DMS/features/spinner/presentation/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/qr_scanner_box.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../scan/providers/scan_provider.dart';
import '../../scan/models/scan_post_data.dart';
import '../../../core/utils/shared_prefs_helper.dart';
import '../../scan/providers/product_level_provider.dart';
import 'package:TrustTags_DMS/features/scan/models/scan_response.dart';


class RetailerScanQRScreen extends StatefulWidget {
  const RetailerScanQRScreen({super.key});

  @override
  State<RetailerScanQRScreen> createState() => _RetailerScanQRScreenState();
}

class _RetailerScanQRScreenState extends State<RetailerScanQRScreen> {
  bool _isLoading = false;
  String scannedUID = '';
  bool get hasPoints =>
      _asyncScans.values.any((e) => e.isValid && !e.isSpinner && e.points > 0);

  bool get hasSpinner =>
      _asyncScans.values.any((e) => e.isValid && e.isSpinner);

  bool get hasInvalid =>
      _asyncScans.values.any((e) => !e.isValid);


  /// Scanner key
  final GlobalKey<ReusableQRScannerState> _scannerKey =
  GlobalKey<ReusableQRScannerState>();

  /// ✅ ASYNC SCAN STORAGE
  final Map<String, AsyncScanResponse> _asyncScans = {};

  int get totalPoints => _asyncScans.values
      .where((e) => e.isProcessed && e.isValid && !e.isSpinner)
      .fold(0, (sum, e) => sum + e.points);

  int get totalSpinners => _asyncScans.values
      .where((e) => e.isProcessed && e.isValid && e.isSpinner)
      .length;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // ----------------------- OUTER SCAN -----------------------
  Future<void> _handleOuterScan(String uid) async {
    scannedUID = uid;
    setState(() {});

    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null || token.isEmpty) return;

    final productLevelProvider =
    Provider.of<ProductLevelProvider>(context, listen: false);

    setState(() => _isLoading = true);
    await productLevelProvider.checkProductLevel(
      ProductLevelRequest(uniqueCode: uid),
    );
    setState(() => _isLoading = false);

    final level =
        productLevelProvider.productLevelResponse?.level ?? '';
    final packagingType =
        productLevelProvider.productLevelResponse?.packagingtype ?? 0;

    if (packagingType == 1) {
      await _validateUid(token, outerCode: uid, packagingtype: packagingType);
      _restartOuterScanner();
      return;
    }

    if (level.toUpperCase() == 'O') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("Now scan the inner code"),
          duration: Duration(seconds: 2),
        ),
      );

      _scannerKey.currentState?.setOnScanned((innerUID) async {
        _scannerKey.currentState?.pauseScanning();
        await _handleInnerScan(
          token,
          outerCode: uid,
          innerCode: innerUID,
        );
      });

      _scannerKey.currentState?.resetScanner();
    } else {
      await _validateUid(token, outerCode: uid);
      _restartOuterScanner();
    }
  }

  // ----------------------- INNER SCAN -----------------------
  Future<void> _handleInnerScan(
      String token, {
        required String outerCode,
        required String innerCode,
      }) async {
    setState(() => _isLoading = true);
    await _validateUid(
      token,
      outerCode: outerCode,
      innerCode: innerCode,
    );
    setState(() => _isLoading = false);
    _restartOuterScanner();
  }
  void _resetScanSession() {
    setState(() {
      _asyncScans.clear();
      scannedUID = '';
    });

    _restartOuterScanner();
  }


  // ----------------------- VALIDATE UID (ASYNC MODE) -----------------------
  Future<void> _validateUid(
      String token, {
        required String outerCode,
        String? innerCode,
        int? packagingtype,
      }) async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);

    final postData = ScanPostData(
      isQrCodeDetected: true,
      uniqueCode: outerCode,
      innerCode: innerCode,
      packagingtype: packagingtype,
    );

    final validateRes = await scanProvider.validateUID(token, postData);

    final scan = _asyncScans.putIfAbsent(
      outerCode,
          () => AsyncScanResponse(uid: outerCode),
    );

    scan.isProcessed = true;

    if (validateRes.success != 1) {
      scan
        ..isValid = false
        ..error = validateRes.message;

      setState(() {}); // ✅ REQUIRED
      return;
    }

    scan.isValid = true;

    // 🎯 SPINNER
    if (validateRes.data is String &&
        validateRes.segments != null &&
        validateRes.segments!.isNotEmpty) {
      scan
        ..isSpinner = true
        ..spinnerId = validateRes.data as String
        ..segments = validateRes.segments;

      setState(() {}); // ✅ REQUIRED
      return;
    }

    // 🎯 POINTS
    if (validateRes.data is Map<String, dynamic>) {
      final scheme = SchemeData.fromJson(validateRes.data);
      scan.points = scheme.points ?? 0;
    }

    setState(() {}); // ✅ REQUIRED
  }

  // ----------------------- SUBMIT FLOW -----------------------
  void _onSubmit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AutoTranslateText(
                  "Scan Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.topBarColor,
                  ),
                ),
                const SizedBox(height: 12),

                Icon(
                  hasSpinner ? Icons.casino : Icons.emoji_events,
                  color: AppColors.topBarColor,
                  size: 48,
                ),

                const SizedBox(height: 20),

                _buildSummaryRow("Total Scans", _asyncScans.length.toString()),

                if (hasPoints)
                  _buildSummaryRow("Total Points", totalPoints.toString()),

                if (hasSpinner)
                  _buildSummaryRow("Spinner Chances", totalSpinners.toString()),

                if (hasInvalid)
                  _buildSummaryRow(
                    "Invalid Scans",
                    _asyncScans.values.where((e) => !e.isValid).length.toString(),
                  ),

                const SizedBox(height: 20),

                // ✅ NEW: Detailed scan breakdown
                if (_asyncScans.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 10),
                  const AutoTranslateText(
                    "Scan Details",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.topBarColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: SingleChildScrollView(
                      child: Column(
                        children: _asyncScans.entries.map((entry) {
                          return _buildScanDetailItem(entry.value);
                        }).toList(),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.topBarColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      if (hasSpinner) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        ).then((_) {
                          _resetScanSession();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: AutoTranslateText("Points added successfully"),
                          ),
                        );
                        _resetScanSession();
                      }
                    },


                    child: AutoTranslateText(
                      hasSpinner ? "Continue" : "Done",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  // ✅ NEW: Build individual scan detail item
  Widget _buildScanDetailItem(AsyncScanResponse scan) {
    IconData icon;
    Color color;
    String status;

    if (!scan.isValid) {
      icon = Icons.cancel;
      color = Colors.red;
      status = "Invalid";
    } else if (scan.isSpinner) {
      icon = Icons.casino;
      color = Colors.purple;
      status = "Spinner";
    } else {
      icon = Icons.check_circle;
      color = Colors.green;
      status = "${scan.points} pts";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan.uid,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!scan.isValid && scan.error != null)
                  Text(
                    scan.error!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AutoTranslateText(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AutoTranslateText(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          AutoTranslateText(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



  // ----------------------- RESTART SCANNER -----------------------
  void _restartOuterScanner() {
    _scannerKey.currentState?.setOnScanned((uid) {
      Future.microtask(() => _handleOuterScan(uid));
    });
    _scannerKey.currentState?.resetScanner();
  }

  // ----------------------- UI -----------------------
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
                      ReusableQRScanner(
                        key: _scannerKey,
                        onScanned: _handleOuterScan,
                      ),
                      const SizedBox(height: 16),
                      _buildScanDetails(),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _asyncScans.isEmpty ? null : _onSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.topBarColor,
                              disabledBackgroundColor: AppColors.topBarColor.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Extra padding at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ ENHANCED: Show scan details with status indicators
  Widget _buildScanDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scannedUID.isNotEmpty) ...[
              const AutoTranslateText(
                'Last Scanned:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.topBarColor,
                ),
              ),
              const SizedBox(height: 4),
              AutoTranslateText(
                scannedUID,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(
                  'Total',
                  _asyncScans.length.toString(),
                  Colors.blue,
                ),
                _buildStatusChip(
                  'Valid',
                  _asyncScans.values.where((e) => e.isValid).length.toString(),
                  Colors.green,
                ),
                _buildStatusChip(
                  'Invalid',
                  _asyncScans.values.where((e) => !e.isValid).length.toString(),
                  Colors.red,
                ),
              ],
            ),

            if (_asyncScans.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (hasPoints)
                    _buildInfoBadge(
                      Icons.emoji_events,
                      '$totalPoints points',
                      Colors.amber,
                    ),
                  if (hasSpinner)
                    _buildInfoBadge(
                      Icons.casino,
                      '$totalSpinners spinners',
                      Colors.purple,
                    ),
                ],
              ),
            ],

            if (_asyncScans.isEmpty)
              const Center(
                child: AutoTranslateText(
                  'No scans yet.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AutoTranslateText(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        AutoTranslateText(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}