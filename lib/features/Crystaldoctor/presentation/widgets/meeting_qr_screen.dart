import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';

class MeetingQrScreen extends StatefulWidget {
  const MeetingQrScreen({super.key});

  @override
  State<MeetingQrScreen> createState() => _MeetingQrScreenState();
}

class _MeetingQrScreenState extends State<MeetingQrScreen> {
  String? meetingId;
  String? meetingName;
  String? orgName;

  @override
  void initState() {
    super.initState();
    _loadMeetingId();
  }

  Future<void> _loadMeetingId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      meetingId = prefs.getString('saved_meeting_id');
      meetingName = prefs.getString('saved_meeting_name');
      orgName = prefs.getString('saved_org_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    final whatsappNumber = "918085742922";

    if (meetingId == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: const [
            AppStatusBar(),
            Spacer(),
            AutoTranslateText(
              "No meeting QR available.\nPlease create a new meeting.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Spacer(),
          ],
        ),
      );
    }

    final message = Uri.encodeComponent(
        "Hii I have attended the meeting\n"
            "Meeting ID: $meetingId\n"
            "Meeting Name: ${meetingName ?? 'N/A'}\n"
            "Organizer: ${orgName ?? 'N/A'}"
    );

    final whatsappLink = "https://wa.me/$whatsappNumber?text=$message";


    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: AutoTranslateText(
                      'Meeting QR Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // 🔹 Center the QR content perfectly
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AutoTranslateText(
                      "Scan this QR to Join WhatsApp Meeting Chat",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: QrImageView(
                        data: whatsappLink,
                        size: 250,
                        version: QrVersions.auto,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AutoTranslateText(
                      "Meeting ID: $meetingId",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    const AutoTranslateText(
                      "WhatsApp Bot: +91 8085742922",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
