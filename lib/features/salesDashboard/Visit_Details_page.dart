import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/home/widgets/discover_carousel.dart';
import 'package:TrustTags_DMS/features/home/widgets/schemes_banner.dart';
import 'package:TrustTags_DMS/features/returns/Add_return_order.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/closure_note_section.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/collection_status_section.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/customer_info_card.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/order_section.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/raise_return_claim_section.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../common/widgets/app_status_bar.dart';
import '../../../common/app_colors.dart';

class VisitDetailsScreen extends StatefulWidget {
  final String? routeStatus;
  const VisitDetailsScreen({super.key,this.routeStatus});

  @override
  State<VisitDetailsScreen> createState() => _VisitDetailsScreenState();
}

class _VisitDetailsScreenState extends State<VisitDetailsScreen> {
  final TextEditingController inventoryController = TextEditingController();
  final TextEditingController closureNoteController = TextEditingController();

  double? latitude;
  double? longitude;

  String? orderId; // 👈 shared orderId
  String? returnOrderId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  @override
  void dispose() {
    inventoryController.dispose();
    closureNoteController.dispose();
    super.dispose();
  }
  void _navigateToAddReturnOrderScreen() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => AddReturnOrderScreen(),
      ),
    );

    // Capture the returnOrderId if it is returned from AddReturnOrderScreen
    if (result != null) {
      setState(() {
        returnOrderId = result; // Store the returnOrderId
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          const AppStatusBar(),

          // Top Bar
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
                const Expanded(
                  child: Center(
                    child: AutoTranslateText(
                      "Visit Details",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomerInfoCard(),
                  const SizedBox(height: 16),

                  // ✅ OrderSection with callback to set orderId
                  OrderSection(
                    orderId: orderId,
                    onOrderPlaced: (newOrderId) {
                      setState(() {
                        orderId = newOrderId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  RaiseReturnClaimSection(
                    returnOrderId: returnOrderId, // 👈 pass state value
                    onAddReturnOrderPlaced: (newReturnOrderId) {
                      setState(() {
                        returnOrderId = newReturnOrderId; // 👈 update state when new one comes
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  const AutoTranslateText(
                    "Check Old Inventory Stock",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _InventoryStockField(controller: inventoryController),
                  const SizedBox(height: 20),

                  const DiscoverCarousel(),
                  const SizedBox(height: 20),
                  const SchemesBanner(),
                  const SizedBox(height: 20),

                  const CollectionStatusSection(),
                  const SizedBox(height: 20),

                  // ✅ Pass orderId to ClosureNoteSection
                  ClosureNoteSection(
                    controller: closureNoteController,
                    inventoryController: inventoryController,
                    lat: latitude,
                    long: longitude,
                    orderId: orderId,
                    returnOrderId:returnOrderId,
                    routeStatus: widget.routeStatus,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryStockField extends StatelessWidget {
  final TextEditingController controller;
  const _InventoryStockField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Enter inventory stock",
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
