import 'dart:convert';
import 'dart:io';
import 'package:TrustTags_DMS/features/authentication/provider/rout_details_provider.dart';
import 'package:TrustTags_DMS/features/authentication/provider/route_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../common/app_colors.dart';
import '../../../../core/utils/shared_prefs_helper.dart';
import '../../../../data/models/Tsi_visited_request.dart';

class ClosureNoteSection extends StatefulWidget {
  final TextEditingController controller;          // comment controller
  final TextEditingController inventoryController; // inventory controller
  final double? lat;
  final double? long;
  final String? orderId;
  final String? returnOrderId;
  final String? routeStatus; // status from VisitDetailsScreen

  const ClosureNoteSection({
    super.key,
    required this.controller,
    required this.inventoryController,
    required this.lat,
    required this.long,
    this.orderId,
    this.returnOrderId,
    this.routeStatus,
  });

  @override
  State<ClosureNoteSection> createState() => _ClosureNoteSectionState();
}

class _ClosureNoteSectionState extends State<ClosureNoteSection> {
  bool _isCompleted = false; // disables button if true
  bool _initialized = false;
  bool _isSubmitting = false;
  File? _capturedPhoto; // captured photo

  @override
  void initState() {
    super.initState();

    // ✅ Initialize _isCompleted from passed routeStatus
    _isCompleted = (widget.routeStatus?.toLowerCase() ?? '') == 'completed';

    // Load API route details
    _loadRouteDetails();
  }

  Future<void> _loadRouteDetails() async {
    final provider = Provider.of<RouteDetailsProviders>(context, listen: false);
    await provider.fetchRouteDetails();

    final statusFromApi = provider.routeDetails?.status?.toLowerCase();
    final comment = provider.routeDetails?.comment ?? '';

    setState(() {
      // ✅ Disable button if either API or passed status is completed
      _isCompleted = _isCompleted || (statusFromApi == 'completed');
      widget.controller.text = comment;
      _initialized = true;
    });
  }

  Future<void> _capturePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _capturedPhoto = File(pickedFile.path));
    }
  }

  Future<void> _submitVisit() async {
    if (_isCompleted || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final double? inventory = double.tryParse(widget.inventoryController.text.trim());
    if (inventory == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid inventory stock")),
      );
      return;
    }

    if (_capturedPhoto == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Photo is required")),
      );
      return;
    }

    final routeVisitProvider = Provider.of<RouteVisitProvider>(context, listen: false);

    final dailyRouteId = await SharedPrefsHelper.getDailyRouteId();
    final locationId = await SharedPrefsHelper.getDailylocationId();

    if (dailyRouteId == null || locationId == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Route or location ID missing")),
      );
      return;
    }

    // Convert photo -> base64
    List<int> imageBytes = await _capturedPhoto!.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final request = TsiVisitedRequest(
      dailyRouteId: dailyRouteId,
      locationId: locationId,
      orderId: widget.orderId ?? "null",
      returnOrderId: widget.returnOrderId ?? "null",
      oldInventoryStock: inventory,
      pendingAmount: 0.0,
      totalCredit: 0.0,
      comment: widget.controller.text.trim(),
      lat: widget.lat ?? 0.0,
      long: widget.long ?? 0.0,
      photo: base64Image,
    );

    await routeVisitProvider.addRouteVisit(request);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (routeVisitProvider.response != null &&
        routeVisitProvider.response!.success == 1) {
      setState(() => _isCompleted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Visit completed successfully")),
      );
      Navigator.pop(context);
    }
    else if (routeVisitProvider.response != null &&
        routeVisitProvider.response!.success == 0) {
      setState(() => _isCompleted = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(routeVisitProvider.response!.message)),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(routeVisitProvider.errorMessage ?? "Error submitting data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Closure Note of Meeting", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: widget.controller,
            maxLines: null,
            decoration: const InputDecoration(border: InputBorder.none),
            enabled: !_isCompleted,
          ),
        ),
        const SizedBox(height: 10),

        // Capture Photo Section
        const Text("Meeting Photo", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _capturedPhoto != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_capturedPhoto!, height: 200),
        )
            : SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCompleted ? null : _capturePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text("Capture Photo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted ? Colors.grey : AppColors.topBarColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: _isCompleted || _isSubmitting ? null : _submitVisit,
            child: _isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(
              _isCompleted ? "Meeting Completed" : "Complete Meeting",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
