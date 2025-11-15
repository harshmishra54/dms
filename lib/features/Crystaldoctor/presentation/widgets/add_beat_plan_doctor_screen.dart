import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/route_by_pincode_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_my_farmers_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/route_by_pincode_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class AddBeatPlanDoctorScreen extends StatefulWidget {
  const AddBeatPlanDoctorScreen({super.key});

  @override
  State<AddBeatPlanDoctorScreen> createState() =>
      _AddBeatPlanDoctorScreenState();
}

class _AddBeatPlanDoctorScreenState extends State<AddBeatPlanDoctorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),

          // 🔹 Top Bar with Tabs
          Material(
            elevation: 3,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: AutoTranslateText(
                            'Add Beat Plan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.topBarColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.topBarColor,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    tabs: const [
                      Tab(text: 'Make Route'),
                      Tab(text: 'By Pincode'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MakeRouteTab(),
                ByPincodeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 🔹 TAB 1: Make Route
// ============================================
class MakeRouteTab extends StatefulWidget {
  const MakeRouteTab({super.key});

  @override
  State<MakeRouteTab> createState() => _MakeRouteTabState();
}

class _MakeRouteTabState extends State<MakeRouteTab> {
  final List<String> _selectedFarmerIds = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _routeNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      context.read<GetMyFarmersProvider>().fetchMyFarmers();
      await context.read<GetBeatPlanDoctorProvider>().fetchBeatPlanDoctor();
    });
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _toggleFarmerSelection(String farmerId) {
    setState(() {
      if (_selectedFarmerIds.contains(farmerId)) {
        _selectedFarmerIds.remove(farmerId);
      } else {
        _selectedFarmerIds.add(farmerId);
      }
    });
  }

  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoTranslateText(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: color ?? AppColors.topBarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitBeatPlan() async {
    final addProvider = context.read<AddBeatPlanDoctorProvider>();
    final beatPlanProvider = context.read<GetBeatPlanDoctorProvider>();

    if (_isSubmitting || addProvider.isLoading) return;

    final selectedDate = _dateController.text.trim();
    final routeName = _routeNameController.text.trim();

    if (routeName.isEmpty) {
      _showSnackBar("Please enter route name", color: Colors.redAccent);
      return;
    }

    if (_selectedFarmerIds.isEmpty) {
      _showSnackBar("Please select at least one farmer",
          color: Colors.redAccent);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await beatPlanProvider.fetchBeatPlanDoctor();
      final existingPlans = beatPlanProvider.beatPlanDoctorResponse?.data ?? [];

      final alreadyExists = existingPlans.any((plan) {
        final planDate = plan.date;
        return planDate != null && planDate == selectedDate;
      });

      if (alreadyExists) {
        _showSnackBar(
          "A Beat Plan already exists for the selected date ($selectedDate)",
          color: Colors.redAccent,
        );
        return;
      }

      await addProvider.addBeatPlanDoctor(
        farmerIds: _selectedFarmerIds,
        date: selectedDate,
        routName: routeName,
      );

      if (addProvider.errorMessage != null) {
        _showSnackBar(addProvider.errorMessage!, color: Colors.redAccent);
      } else if (addProvider.response != null) {
        _showSnackBar(addProvider.response!.message, color: Colors.green);
        Navigator.pop(context, true);
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerProvider = context.watch<GetMyFarmersProvider>();

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Route Name Input
                TextField(
                  controller: _routeNameController,
                  decoration: const InputDecoration(
                    labelText: "Enter Route Name",
                    prefixIcon: Icon(Icons.alt_route),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Date Picker
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Select Date",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          _dateController.text =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                        }
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Farmer List
                Expanded(
                  child: Builder(
                    builder: (_) {
                      if (farmerProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.topBarColor),
                        );
                      } else if (farmerProvider.errorMessage != null) {
                        return Center(
                          child: AutoTranslateText(
                            farmerProvider.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      } else if (farmerProvider.farmers.isEmpty) {
                        return const Center(
                            child: AutoTranslateText("No farmers found"));
                      } else {
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: farmerProvider.farmers.length,
                          itemBuilder: (context, index) {
                            final farmer = farmerProvider.farmers[index];
                            final isSelected =
                            _selectedFarmerIds.contains(farmer.id ?? "");

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 1,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) =>
                                    _toggleFarmerSelection(farmer.id ?? ""),
                                title: AutoTranslateText(
                                  farmer.name ?? "Unknown Farmer",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: AutoTranslateText(
                                  "Area: ${farmer.area ?? 'N/A'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Button
        SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.topBarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: (_isSubmitting) ? null : _submitBeatPlan,
                child: _isSubmitting
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    AutoTranslateText(
                      "Please wait...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : const AutoTranslateText(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// 🔹 TAB 2: By Pincode
// ============================================
class ByPincodeTab extends StatefulWidget {
  const ByPincodeTab({super.key});

  @override
  State<ByPincodeTab> createState() => _ByPincodeTabState();
}

class _ByPincodeTabState extends State<ByPincodeTab> {
  final TextEditingController _pincodeController = TextEditingController();
  String? _lat;
  String? _lng;
  String _currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        _lat = position.latitude.toString();
        _lng = position.longitude.toString();

        _currentAddress =
        "${place.street}, ${place.locality}, ${place.subLocality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = "Address not found";
      });
    }
  }

  void _onPincodeChanged(String value) {
    if (value.length == 6 && _lat != null && _lng != null) {
      final provider =
      Provider.of<RouteByPincodeProvider>(context, listen: false);
      provider.fetchRouteByPincode(
        RouteRequestModel(
          pincode: int.parse(value),
          originLat: _lat!,
          originLng: _lng!,
        ),
      );
    }
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    }
  }

  Future<void> _openGoogleMaps(
      String lat, String lng, String destinationName) async {
    final uri = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&origin=$_lat,$_lng&destination=$lat,$lng&travelmode=driving");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _callFarmer(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RouteByPincodeProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Card
            if (_lat != null && _lng != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.my_location,
                        color: Colors.purple[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your Location",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Pincode Input Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: "Enter Pincode",
                  hintText: "Enter 6-digit pincode",
                  prefixIcon: Icon(Icons.pin_drop, color: Colors.purple[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.purple[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    BorderSide(color: Colors.purple[700]!, width: 2),
                  ),
                  counterText: "",
                ),
                onChanged: _onPincodeChanged,
              ),
            ),

            const SizedBox(height: 24),

            // Loader
            if (provider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),

            // Error message
            if (provider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: TextStyle(color: Colors.red[900]),
                      ),
                    ),
                  ],
                ),
              ),

            // Results UI
            if (provider.routeResponse != null &&
                provider.routeResponse!.route != null) ...[
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.people,
                      title: "Total Farmers",
                      value: "${provider.routeResponse!.totalFarmers}",
                      color: AppColors.topBarColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.route,
                      title: "Total Distance",
                      value: "${provider.routeResponse!.totalDistanceKm} km",
                      color: AppColors.topBarColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Route Header
              Row(
                children: [
                  Icon(Icons.map, color: Colors.purple[700], size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Optimized Route",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.routeResponse!.route!.length,
                itemBuilder: (context, index) {
                  final farmer = provider.routeResponse!.route![index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            farmer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.phone,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      farmer.phone,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.navigation,
                                        size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatDistance(
                                          farmer.distanceFromPrev.toDouble()),
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action Buttons
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _callFarmer(farmer.phone),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.call,
                                            size: 18, color: Colors.green[700]),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Call",
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _openGoogleMaps(
                                    farmer.latitude.toString(),
                                    farmer.longitude.toString(),
                                    farmer.name,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.directions,
                                            size: 18, color: Colors.blue[700]),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Navigate",
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}