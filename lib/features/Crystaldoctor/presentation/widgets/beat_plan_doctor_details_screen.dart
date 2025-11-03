import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/visit_rout_crystal_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/update_beat_plan_doctor_provider.dart';

class BeatPlanDoctorDetailsScreen extends StatelessWidget {
  final String date;
  final String routeName;
  final List<dynamic> farmers;
  final String routeId;
  final String routeStatus;

  const BeatPlanDoctorDetailsScreen({
    super.key,
    required this.date,
    required this.routeName,
    required this.farmers,
    required this.routeId,
    required this.routeStatus,
  });

  String _getValue(dynamic farmer, String key) {
    try {
      if (farmer == null) return '';
      if (farmer is Map<String, dynamic>) {
        return (farmer[key] ?? '').toString();
      } else {
        final value = farmer.toJson()[key] ?? '';
        return value.toString();
      }
    } catch (_) {
      try {
        switch (key) {
          case 'id':
            return farmer.id?.toString() ?? '';
          case 'name':
            return farmer.name?.toString() ?? '';
          case 'phone':
            return farmer.phone?.toString() ?? '';
          case 'area':
            return farmer.area?.toString() ?? '';
          case 'address':
            return farmer.address?.toString() ?? '';
          case 'status':
            return farmer.status?.toString() ?? '';
        }
      } catch (_) {}
      return '';
    }
  }

  bool _isAnyFarmerPending() {
    return farmers.any((f) => _getValue(f, 'status') != 'Completed');
  }

  void _showReasonDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Enter Reason",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Enter reason for incomplete farmers...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            Consumer<UpdateBeatPlanDoctorProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    final reason = reasonController.text.trim();
                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a reason."),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(ctx);

                    final success = await provider.updateBeatPlanDoctor(
                      id: routeId,
                      status: "Completed",
                      reason: reason,
                    );

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.response?.message ??
                                  "Route completed successfully!",
                            ),
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.errorMessage ??
                                  "Failed to complete route.",
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: provider.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("OK"),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnyPending = _isAnyFarmerPending();
    final isRouteCompleted = routeStatus == "Completed";

    return ChangeNotifierProvider(
      create: (_) => UpdateBeatPlanDoctorProvider(),
      child: Consumer<UpdateBeatPlanDoctorProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              top: false,
              child: Column(
                children: [
                  const AppStatusBar(),

                  /// Custom Container AppBar
                  Material(
                    elevation: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                            ),
                          ),
                          Center(
                            child: Text(
                              routeName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
                      child: farmers.isEmpty
                          ? const Center(
                        child: Text(
                          "No farmers found for this date",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      )
                          : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: farmers.length,
                        itemBuilder: (context, index) {
                          final farmer = farmers[index];
                          final id = _getValue(farmer, 'id');
                          final name = _getValue(farmer, 'name');
                          final phone = _getValue(farmer, 'phone');
                          final area = _getValue(farmer, 'area');
                          final address = _getValue(farmer, 'address');
                          final status = _getValue(farmer, 'status');

                          return GestureDetector(
                            onTap: () {
                              if (id.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Farmer ID not found.")),
                                );
                                return;
                              }

                              // ✅ Navigate with farmer details
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FarmerMeetingScreen(
                                    farmerId: id,
                                    farmerPhone: phone,
                                    routeId: routeId,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.purple,
                                          child: Icon(Icons.person, color: Colors.white),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            name.isNotEmpty ? name : 'Unknown Farmer',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: status == "Completed"
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: status == "Completed"
                                                  ? Colors.green.shade800
                                                  : Colors.orange.shade800,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (area.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 16, color: Colors.purple),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Area In Acre: $area",
                                            style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 6),
                                    if (address.isNotEmpty)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.home,
                                              size: 16, color: Colors.purple),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              address,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  /// Complete Button (only if not already completed)
                  if (!isRouteCompleted && isAnyPending)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed:
                          provider.isLoading ? null : () => _showReasonDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                              : const Text(
                            "Complete Route",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  /// Disabled Button if already completed
                  if (isRouteCompleted)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade400,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Route Completed",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}