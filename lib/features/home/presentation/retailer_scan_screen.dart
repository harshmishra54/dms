import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/crop_provider.dart';
import 'package:TrustTags_DMS/features/scan/models/product_level_check_model.dart';
import 'package:TrustTags_DMS/features/scan/providers/add_purchase_provider.dart';
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
  String scannedUID = '';
  bool _isLoading = false;

  /// GlobalKey for scanner
  final GlobalKey<ReusableQRScannerState> _scannerKey =
  GlobalKey<ReusableQRScannerState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  // ----------------------- Scan Result Dialog -----------------------
  void _showScanResultDialog({
    required bool isValid,
    required String productName,
    required String points,
  }) {
    final color = isValid ? Colors.green : Colors.redAccent;
    final title = isValid ? "Valid Scan" : "Invalid Scan";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

                // ✔ Points only
                _buildReadOnlyField("Points", points),
                const SizedBox(height: 15),

                // ✔ Product Name only
                _buildReadOnlyField("Product Name", productName),

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
                      _restartOuterScanner();
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

  // ----------------------- Outer Scan -----------------------
  Future<void> _handleOuterScan(String uid) async {
    setState(() {
      scannedUID = uid;
      _isLoading = true;
    });

    final token = await SharedPrefsHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      setState(() => _isLoading = false);
      _showScanResultDialog(
        isValid: false,
        productName: "Token Missing",
        // productUID: uid,
        points: "0",
        // message: "Authentication token missing",
      );
      return;
    }

    final productLevelProvider =
    Provider.of<ProductLevelProvider>(context, listen: false);

    await productLevelProvider.checkProductLevel(
      ProductLevelRequest(uniqueCode: uid),
    );

    setState(() => _isLoading = false);

    if (productLevelProvider.errorMessage != null) {
      _showScanResultDialog(
        isValid: false,
        productName: "Error",
        // productUID: uid,
        points: "0",
        // message: productLevelProvider.errorMessage!,
      );
      return;
    }

    final level = productLevelProvider.productLevelResponse?.level ?? '';
    final packagingType = productLevelProvider.productLevelResponse?.packagingtype ?? 0;

    if (packagingType == 1) {
      await _validateUid(token, outerCode: uid,packagingtype: packagingType);
      return;
    }
    if (level.toUpperCase() == 'O') {
      // Show 1 second info messages
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: AutoTranslateText("Now scan the inner code...",style: TextStyle(color: Colors.red),),
          duration: Duration(seconds: 2),
        ),
      );

      // Switch scanner to inner scan
      _scannerKey.currentState?.setOnScanned((innerUID) async {
        _scannerKey.currentState?.pauseScanning();
        await _handleInnerScan(token, outerCode: uid, innerCode: innerUID);
      });

      _scannerKey.currentState?.resetScanner();
    } else {
      await _validateUid(token, outerCode: uid);
    }
  }
  Future<String?> _showCropNameDialog() async {
    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    // Fetch crop list before showing dialog
    await cropProvider.fetchCropList();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        String? selectedCrop;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Consumer<CropProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.errorMessage != null) {
                  return SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Failed to load crops",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        // const SizedBox(height: 10),
                        // Text(provider.errorMessage!,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(color: Colors.red)),
                        // const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                }

                final crops = provider.cropResponse?.data ?? [];

                if (crops.isEmpty) {
                  return SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("No crops available",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Crop",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    // Dropdown
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      value: selectedCrop,
                      hint: const Text("Choose Crop"),
                      items: crops.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop.cropTypeName ?? "",
                          child: Text(crop.cropTypeName ?? ""),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedCrop = value;
                      },
                    ),

                    const SizedBox(height: 20),

                    // OK Button
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.topBarColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (selectedCrop == null) return;
                          Navigator.pop(context, selectedCrop);
                        },
                        child: const Text("OK",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }



  // ----------------------- Inner Scan -----------------------
  Future<void> _handleInnerScan(
      String token, {
        required String outerCode,
        required String innerCode,
      }) async {
    setState(() => _isLoading = true);
    await _validateUid(token, outerCode: outerCode, innerCode: innerCode);
    setState(() => _isLoading = false);
  }

  // ----------------------- Validate UID -----------------------
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
      packagingtype: packagingtype
    );

    final validateRes = await scanProvider.validateUID(token, postData);

    // Handle Spinner response case
    if (validateRes.data is String &&
        validateRes.segments != null &&
        validateRes.segments!.isNotEmpty) {

      // ✅ Show crop dialog + API call only for roleId 3
      final roleId = await SharedPrefsHelper.getRoleId();
      final userId = await SharedPrefsHelper.getUserId();
if(validateRes.success == 1) {
  if (roleId == 3 && userId != null) {
    final cropName = await _showCropNameDialog();
    if (cropName != null && cropName.isNotEmpty) {
      final added = await Provider.of<AddPurchaseProvider>(
          context, listen: false)
          .addPurchaseProduct(
          userId: userId, cropName: cropName, roleId: roleId ?? 0);

      if (!added) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add purchase: ${Provider
                .of<AddPurchaseProvider>(context, listen: false)
                .errorMessage ?? ""}"),
          ),
        );
      }
    }
  }
}

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpinnerWidget(
            spinnerId: validateRes.data as String,
            segments: validateRes.segments!,
          ),
        ),
      );

      _restartOuterScanner();
      return;
    }

    // ✅ Convert to SchemeData safely if data is Map
    SchemeData? schemeData;
    if (validateRes.data is Map<String, dynamic>) {
      schemeData = SchemeData.fromJson(validateRes.data);
    }

    // ✅ Show crop dialog + API only for roleId 3 before showing direct reward
    final roleId2 = await SharedPrefsHelper.getRoleId();
    final userId2 = await SharedPrefsHelper.getUserId();

    if (roleId2 == 3 && userId2 != null) {
      final cropName = await _showCropNameDialog();
      if (cropName != null && cropName.isNotEmpty) {
        final added = await Provider.of<AddPurchaseProvider>(context, listen: false)
            .addPurchaseProduct(userId: userId2, cropName: cropName, roleId: roleId2?? 0);

        if (!added) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to add purchase: ${Provider.of<AddPurchaseProvider>(context, listen: false).errorMessage ?? ""}"),
            ),
          );
        }
      }
    }

    // ✅ Now handle success & failure properly
    if (validateRes.success == 1 && schemeData != null) {
      _showScanResultDialog(
        isValid: true,
        productName: schemeData.productName ?? "Unknown Product",
        // productUID: schemeData.schemeUID ?? outerCode,
        points: (schemeData.points ?? 0).toString(),
        // message: schemeData.message?.isNotEmpty == true
        //     ? schemeData.message!
        //     : validateRes.message.isNotEmpty
        //     ? validateRes.message
            // : "Scan successful",
      );
    } else {
      _showScanResultDialog(
        isValid: false,
        productName: "Not Valid",
        // productUID: outerCode,
        points: "0",
        // message: validateRes.message.isNotEmpty
        //     ? validateRes.message
        //     : "Invalid QR code",
      );
    }
  }

  // ----------------------- Restart scanner for outer mode -----------------------
  void _restartOuterScanner() {
    _scannerKey.currentState?.setOnScanned((uid) {
      Future.microtask(() => _handleOuterScan(uid));
    });
    _scannerKey.currentState?.resetScanner();
  }

  // ----------------------- Build UI -----------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // allows resizing when keyboard appears
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          SingleChildScrollView(   // <-- Added
            child: Column(
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
                ReusableQRScanner(
                  key: _scannerKey,
                  onScanned: (uid) => _handleOuterScan(uid),
                ),
                const SizedBox(height: 20),
                _buildScanDetails(),
                const SizedBox(height: 30),
              ],
            ),
          ),
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
