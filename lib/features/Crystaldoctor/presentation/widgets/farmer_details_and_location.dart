// file: phone_location_screen.dart

import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/list_farmer_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geocoding/geocoding.dart'; // ✅ For reverse geocoding

class PhoneLocationScreen extends StatefulWidget {
  const PhoneLocationScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLocationScreen> createState() => _PhoneLocationScreenState();
}

class _PhoneLocationScreenState extends State<PhoneLocationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  LatLng? _markerLocation;
  String? _placeName;
  late final AnimatedMapController _animatedMapController;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);

    // Clear old provider data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      Provider.of<FarmerDetailsProvider>(context, listen: false);
      provider.reset();
    });
  }

  /// ✅ Fetch farmer and reverse geocode
  Future<void> _fetchLocation() async {
    final provider =
    Provider.of<FarmerDetailsProvider>(context, listen: false);

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter phone number")));
      return;
    }

    // Hide keyboard if 10 digits entered
    if (phone.length == 10) FocusScope.of(context).unfocus();

    await provider.fetchFarmerDetails(phone);

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      return;
    }

    final data = provider.farmerDetails?.data;
    if (data != null && data.latitude != null && data.longitude != null) {
      final newLocation = LatLng(data.latitude!, data.longitude!);
      setState(() {
        _markerLocation = newLocation;
        _placeName = "Loading…"; // temporary
      });

      // Smooth zoom animation
      _animatedMapController.animateTo(
        dest: newLocation,
        zoom: 16.5,
        curve: Curves.easeInOut,
        duration: const Duration(seconds: 2),
      );

      // Reverse geocode to get the address
      try {
        final placemarks =
        await placemarkFromCoordinates(data.latitude!, data.longitude!);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          setState(() {
            _placeName =
            "${place.subLocality ?? place.locality ?? place.administrativeArea ?? place.country}";
          });
        } else {
          setState(() => _placeName = "Unknown location");
        }
      } catch (e) {
        setState(() => _placeName = "Failed to get location name");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No location data found for this farmer.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FarmerDetailsProvider>(
      builder: (context, provider, _) {
        final farmer = provider.farmerDetails?.data;
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
                          'Farmer Location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              // Input Section
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter mobile number",
                          counterText: "",
                        ),
                        onChanged: (value) {
                          if (value.length == 10) {
                            FocusScope.of(context).unfocus();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    provider.isLoading
                        ? const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : IconButton(
                      onPressed: _fetchLocation,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.topBarColor,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),

              // Map Section
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    mapController: _animatedMapController.mapController,
                    options: MapOptions(
                      initialCenter: _markerLocation ?? LatLng(20.5937, 78.9629),
                      initialZoom: _markerLocation != null ? 12 : 5,
                      interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                        'https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',
                        subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                        userAgentPackageName: 'com.trusttags.trusttags_dms',
                      ),
                      if (_markerLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _markerLocation!,
                              width: 300,
                              height: 120,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          farmer?.name ?? "Farmer", // ✅ Farmer name
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _placeName ?? "Loading…", // ✅ Place name
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      RichAttributionWidget(
                        attributions: [
                          TextSourceAttribution(
                            'Map data © Google / OpenStreetMap',
                            onTap: () => launchUrl(
                              Uri.parse(
                                  'https://www.google.com/maps/@?api=1&map_action=map'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Farmer Info Card
              if (farmer != null)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.topBarColor,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(farmer.name),
                      subtitle: Text("📍$_placeName"),
                      trailing: _markerLocation != null
                          ? TextButton.icon(
                        onPressed: () => launchUrl(Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${_markerLocation!.latitude},${_markerLocation!.longitude}')),
                        icon: const Icon(Icons.navigation, color: AppColors.topBarColor),
                        label: const Text(
                          "Navigate",
                          style: TextStyle(color:AppColors.topBarColor, fontSize: 14),
                        ),
                      )
                          : null,

                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
