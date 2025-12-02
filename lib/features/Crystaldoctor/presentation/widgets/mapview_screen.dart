import 'dart:math';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_activity_timeline_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/data/models/activity_timeline_model.dart';
import 'package:geocoding/geocoding.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> with TickerProviderStateMixin {
  late final AnimatedMapController _animatedMapController;

  @override
  void initState() {
    super.initState();
    _animatedMapController = AnimatedMapController(vsync: this);

    // Fetch timeline data on load
    Future.microtask(() {
      context.read<GetActivityTimelineProvider>().fetchActivityTimeline();
    });
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    super.dispose();
  }

  double _calculateTotalDistance(List<LatLng> points) {
    if (points.length < 2) return 0;
    final distance = Distance();
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distance(points[i], points[i + 1]);
    }
    return total / 1000; // km
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        LatLng(23.0225, 72.5714),
        LatLng(23.0225, 72.5714),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    // Add padding
    final latPadding = (maxLat - minLat) * 0.2;
    final lngPadding = (maxLng - minLng) * 0.2;

    return LatLngBounds(
      LatLng(minLat - latPadding, minLng - lngPadding),
      LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = _calculateBounds(points);
    _animatedMapController.animatedFitCamera(
      cameraFit: CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        List<String> addressParts = [];

        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
      }
    } catch (e) {
      print("Error getting address: $e");
    }
    return "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}";
  }

  void _showVisitDetails(BuildContext context, ActivityData data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FutureBuilder<String>(
        future: () async {
          if (data.latitude != null && data.longitude != null) {
            try {
              final lat = double.tryParse(data.latitude ?? '') ?? 0.0;
              final lng = double.tryParse(data.longitude ?? '') ?? 0.0;
              return await _getAddressFromLatLng(lat, lng);
            } catch (e) {
              return "Location unavailable";
            }
          }
          return "Location unavailable";
        }(),
        builder: (context, snapshot) {
          final locationText = snapshot.data ?? "Loading location...";

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                // Store icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.store_mall_directory,
                    color: Colors.deepPurple,
                    size: 32,
                  ),
                ),

                const SizedBox(height: 12),

                // Name
                AutoTranslateText(
                  data.name ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Type badge (if available)
                if (data.address != null && data.address!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                    child: AutoTranslateText(
                      data.address!,
                      style: const TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Info rows
                _buildInfoRow(
                  Icons.location_on,
                  "Location",
                  locationText,
                  isLoading: snapshot.connectionState == ConnectionState.waiting,
                ),

                const SizedBox(height: 20),

                // Action buttons
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLoading = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.deepPurple),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoTranslateText(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              )
                  : AutoTranslateText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GetActivityTimelineProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return Stack(
              children: [
                const AppStatusBar(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                      ),
                      const SizedBox(height: 16),
                      AutoTranslateText(
                        "Loading route data...",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Error state
          if (provider.errorMessage != null) {
            return Stack(
              children: [
                const AppStatusBar(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        // const SizedBox(height: 16),
                        // AutoTranslateText(
                        //   "No Route Found",
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.w600,
                        //     color: Colors.grey[800],
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        AutoTranslateText(
                          provider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const AutoTranslateText("Retry"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.topBarColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            provider.fetchActivityTimeline();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Empty state
          final dataList = provider.activityTimelineResponse?.data ?? [];
          if (dataList.isEmpty) {
            return Stack(
              children: [
                const AppStatusBar(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      AutoTranslateText(
                        "No route data available",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AutoTranslateText(
                        "Complete some visits to see the route",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Convert API data to LatLng points
          final routePoints = dataList
              .where((e) => e.latitude != null && e.longitude != null)
              .map((e) {
            try {
              final lat = double.tryParse(e.latitude ?? '') ?? 0.0;
              final lng = double.tryParse(e.longitude ?? '') ?? 0.0;
              if (lat == 0.0 || lng == 0.0) return null;
              return LatLng(lat, lng);
            } catch (e) {
              return null;
            }
          })
              .whereType<LatLng>()
              .toList();

          if (routePoints.isEmpty) {
            return const Center(
              child: AutoTranslateText("Invalid location data in route"),
            );
          }

          final totalDistance = _calculateTotalDistance(routePoints).toStringAsFixed(2);

          // Fit bounds after building the map
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitBounds(routePoints);
          });

          return Stack(
            children: [
              const AppStatusBar(),

              // Map Section
              FlutterMap(
                mapController: _animatedMapController.mapController,
                options: MapOptions(
                  initialCenter: routePoints.first,
                  initialZoom: 11,
                  minZoom: 5,
                  maxZoom: 18,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // Google Satellite + Hybrid tiles
                  TileLayer(
                    urlTemplate: 'https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    userAgentPackageName: 'com.trusttags.trusttags_dms',
                  ),

                  // Route line with gradient effect
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: Colors.deepPurple,
                        strokeWidth: 6,
                        borderColor: Colors.white,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),

                  // Markers
                  MarkerLayer(
                    markers: [
                      for (int i = 0; i < dataList.length; i++)
                        if (dataList[i].latitude != null &&
                            dataList[i].longitude != null)
                          Marker(
                            point: () {
                              try {
                                final lat = double.tryParse(dataList[i].latitude ?? '') ?? 0.0;
                                final lng = double.tryParse(dataList[i].longitude ?? '') ?? 0.0;
                                return LatLng(lat, lng);
                              } catch (e) {
                                return LatLng(0, 0);
                              }
                            }(),
                            width: 100,
                            height: 100,
                            child: GestureDetector(
                              onTap: () => _showVisitDetails(context, dataList[i]),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Marker with number
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.deepPurple,
                                              Colors.purple.shade700,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: AutoTranslateText(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // Label
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    constraints: const BoxConstraints(
                                      maxWidth: 120,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.deepPurple.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: AutoTranslateText(
                                      dataList[i].name ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ],
              ),

              // AppBar Overlay
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 12,
                right: 12,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: AutoTranslateText(
                            "Activity Route Map",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black87),
                          onPressed: () {
                            provider.fetchActivityTimeline();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Summary Card
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.purple.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              Icons.route,
                              totalDistance,
                              "km",
                              Colors.deepPurple,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStat(
                              Icons.location_on,
                              "${dataList.length}",
                              "Total Stops",
                              Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        AutoTranslateText(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        AutoTranslateText(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}