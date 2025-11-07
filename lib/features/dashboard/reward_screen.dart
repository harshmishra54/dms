import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:TrustTags_DMS/common/widgets/qr_scanner_box.dart';
import '../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<RewardScreen> {
  String scannedUID = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ));
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

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ReusableQRScanner(
                    onScanned: (uid) {
                      setState(() => scannedUID = uid);
                    },
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
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter UID manually',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle submit
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
                  ),

                  const SizedBox(height: 24),

                  // Scan Details
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
