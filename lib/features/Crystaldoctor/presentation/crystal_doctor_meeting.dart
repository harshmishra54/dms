import 'dart:convert';
import 'dart:io';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/meeting_qr_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/route_meeting_models.dart';
import 'package:TrustTags_DMS/features/dashboard/provider/meeting_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/date_time_picker_field.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/event_photos_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrystalDoctorMeeting extends StatefulWidget {
  const CrystalDoctorMeeting({super.key});

  @override
  State<CrystalDoctorMeeting> createState() => _CrystalDoctorMeetingState();
}

class _CrystalDoctorMeetingState extends State<CrystalDoctorMeeting> {
  final _meetingNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _routeNameController = TextEditingController();
  final _meetingDateTimeController = TextEditingController();
  final _eventNotesController = TextEditingController();
  final _eventActionsController = TextEditingController();
  final _cropFocusController = TextEditingController();
  final _productDiscussedController = TextEditingController();
  final _schemesDiscussedController = TextEditingController();
  final _meetingdurationController = TextEditingController();

  final List<File> _eventPhotos = [];
  String? _location;
  bool _isSubmitting = false;

  final List<String> _meetingTypes = [
    "Farmer Awareness Meeting",
    "Product Promotion",
    "Product Demo",
    "Farmer Club Meeting"
  ];
  String? _selectedMeetingType;

  @override
  void initState() {
    super.initState();
    _prefillPhoneNumber();
    _fetchLocation();
  }

  Future<void> _prefillPhoneNumber() async {
    final phone = await SharedPrefsHelper.getPhone();
    if (!mounted) return;
    _mobileNumberController.text = phone ?? '';
  }
  Future<void> saveMeetingId(String meetingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_meeting_id', meetingId);
    print("✅ Meeting ID saved locally: $meetingId");
  }


  Future<void> _fetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    Position position =
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _location = "${position.latitude},${position.longitude}";
    });
  }

  @override
  void dispose() {
    _meetingNameController.dispose();
    _mobileNumberController.dispose();
    _routeNameController.dispose();
    _meetingDateTimeController.dispose();
    _eventNotesController.dispose();
    _eventActionsController.dispose();
    _cropFocusController.dispose();
    _productDiscussedController.dispose();
    _schemesDiscussedController.dispose();
    _meetingdurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Colors.grey),
    );

    return Scaffold(
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
                    child: Text(
                      'Create Meeting',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Meeting Type', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: _selectedMeetingType,
                    items: _meetingTypes
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(fontSize: 14)),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedMeetingType = value),
                    decoration: InputDecoration(
                      hintText: "Select meeting type",
                      border: inputBorder,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Meeting Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _meetingNameController,
                    decoration: InputDecoration(
                        hintText: 'Enter meeting name', border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  const Text('Place Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _routeNameController,
                    decoration: InputDecoration(
                        hintText: 'Enter Place name', border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  const Text('Meeting Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DateTimePickerField(
                    controller: _meetingDateTimeController,
                    hintText: 'Tap to select date and time',
                  ),
                  const SizedBox(height: 12),
                  const Text('Meeting Duration',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _meetingdurationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter duration in hours',
                      border: inputBorder,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Crop Focus', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _cropFocusController,
                    decoration:
                    InputDecoration(hintText: 'Enter crop focus', border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  const Text('Product Discussed',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _productDiscussedController,
                    decoration: InputDecoration(
                        hintText: 'Enter product discussed', border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  const Text('Schemes Discussed',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _schemesDiscussedController,
                    decoration: InputDecoration(
                        hintText: 'Enter schemes discussed', border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  EventPhotosSection(
                    eventPhotos: _eventPhotos,
                    onPhotosChanged: (updated) {
                      setState(() {
                        _eventPhotos.clear();
                        _eventPhotos.addAll(updated);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Event Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _eventNotesController,
                    maxLines: 3,
                    decoration: InputDecoration(border: inputBorder),
                  ),
                  const SizedBox(height: 12),
                  const Text('Event Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _eventActionsController,
                    maxLines: 3,
                    decoration: InputDecoration(border: inputBorder),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                        setState(() => _isSubmitting = true);
                        try {
                          final tsiId = await SharedPrefsHelper.getUserId() ?? '';
                          final phone = await SharedPrefsHelper.getPhone() ?? '';
                          final List<String> eventPhotos = _eventPhotos
                              .map((file) => base64Encode(file.readAsBytesSync()))
                              .toList();

                          final req = RouteMeetingRequest(
                            tsiId: tsiId,
                            routeId: 23,
                            meetingName: _meetingNameController.text.trim(),
                            meetingType:
                            _selectedMeetingType ?? "Farmer Meeting",
                            location: _location ?? "",
                            cropFocus: _cropFocusController.text.trim(),
                            mobileNumber: phone,
                            meetingDate: DateTime.tryParse(
                                _meetingDateTimeController.text.trim()) ??
                                DateTime.now(),
                            duration: int.tryParse(
                                _meetingdurationController.text.trim()) ??
                                0,
                            routeName: _routeNameController.text.trim(),
                            eventPhotos: eventPhotos,
                            eventNotes: _eventNotesController.text.trim(),
                            eventAction: _eventActionsController.text.trim(),
                            productDiscussed:
                            _productDiscussedController.text.trim(),
                            schemesDiscussed:
                            _schemesDiscussedController.text.trim(),
                          );

                          final provider = MeetingProvider();
                          final res = await provider.submitMeeting(req);

                          if (!mounted) return;

                          if (res.success == 1) {
                            final prefs = await SharedPreferences.getInstance();

                            if (res.meetinId != null) {
                              await prefs.setString('saved_meeting_id', res.meetinId!);
                            }

                            // 🟢 Add these lines to save extra info
                            if (res.meetingName != null) {
                              await prefs.setString('saved_meeting_name', res.meetingName!);
                            }
                            if (res.organiserName != null) {
                              await prefs.setString('saved_org_name', res.organiserName!);
                            }

                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(res.message)));

                            // ✅ Navigate to Meeting QR Screen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const MeetingQrScreen()),
                            );
                          }

                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${res.message}')),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit: $e')),
                          );
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA259FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
