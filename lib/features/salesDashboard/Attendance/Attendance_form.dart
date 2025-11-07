import 'dart:convert';
import 'dart:io';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/attendance_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/face_detection.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/attendance_mark_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';


Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return null;
  }

  if (permission == LocationPermission.deniedForever) return null;

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

class AttendanceFormScreen extends StatefulWidget {
  final String mode; // "leave" or "working"

  const AttendanceFormScreen({super.key, required this.mode});

  @override
  State<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  final _reasonController = TextEditingController();
  File? _selfie;
  Position? _currentPosition;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final position = await getCurrentLocation();
    setState(() {
      _currentPosition = position;
    });
  }

  Future<void> _captureSelfie() async {
    final selfie = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const SelfieCameraScreen()),
    );
    if (selfie != null) {
      setState(() => _selfie = selfie);
    }
  }



  void _submit() async {
    final attendanceProvider =
    Provider.of<AttendanceSubmitProvider>(context, listen: false);

    if (widget.mode == "leave") {
      if (_reasonController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoTranslateText("Please enter a reason")),
        );
        return;
      }
    } else {
      if (_selfie == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoTranslateText("Please capture a selfie")),
        );
        return;
      }

      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: AutoTranslateText("Fetching location, please wait...")),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    // Convert image to base64 if working mode
    String base64Image = '';
    if (_selfie != null) {
      List<int> imageBytes = await _selfie!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    // Prepare request
    // Prepare request
    AttendanceRequest request = AttendanceRequest(
      type: widget.mode == "leave" ? 0 : 1,
      reason: widget.mode == "leave" ? _reasonController.text : '',
      latLong: '${_currentPosition?.latitude ?? 0},${_currentPosition?.longitude ?? 0}', // ✅ always send location
      attendancePhoto: base64Image,
    );


    await attendanceProvider.submitAttendance(request);

    setState(() => _isSubmitting = false);

    if (attendanceProvider.attendanceResponse != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(attendanceProvider.attendanceResponse!.message)),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(attendanceProvider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const AppStatusBar(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.white,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
                const SizedBox(width: 12),
                AutoTranslateText(
                  widget.mode == "leave" ? "Leave Form" : "Mark Attendance",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.mode == "leave") ...[
                      const AutoTranslateText(
                        "Reason for Leave",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _reasonController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: "Enter your reason...",
                        ),
                      ),
                    ] else ...[
                      const AutoTranslateText(
                        "Selfie",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      _selfie != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selfie!, height: 250),
                      )
                          : ElevatedButton.icon(
                        onPressed: _captureSelfie,
                        icon: const Icon(Icons.camera_alt),
                        label: const AutoTranslateText("Capture Selfie"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    _isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: AppColors.topBarColor,
                      ),
                      child: AutoTranslateText(
                        widget.mode == "leave"
                            ? "Submit Leave"
                            : "Mark Attendance",
                        style: const TextStyle(
                            fontSize: 16, color: Colors.white),
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
