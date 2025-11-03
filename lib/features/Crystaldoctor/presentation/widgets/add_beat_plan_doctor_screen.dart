import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_beat_plan_doctor_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_my_farmers_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/get_beat_plan_doctor_provider.dart';

class AddBeatPlanDoctorScreen extends StatefulWidget {
  const AddBeatPlanDoctorScreen({super.key});

  @override
  State<AddBeatPlanDoctorScreen> createState() =>
      _AddBeatPlanDoctorScreenState();
}

class _AddBeatPlanDoctorScreenState extends State<AddBeatPlanDoctorScreen> {
  final List<String> _selectedFarmerIds = [];
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _routeNameController = TextEditingController();
  bool _isSubmitting = false; // 🔹 Button loader state

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

  /// 🔹 Styled snackbar
  void _showSnackBar(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
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

  /// 🔹 Submit Beat Plan Logic with Validation
  Future<void> _submitBeatPlan() async {
    final addProvider = context.read<AddBeatPlanDoctorProvider>();
    final beatPlanProvider = context.read<GetBeatPlanDoctorProvider>();

    if (_isSubmitting || addProvider.isLoading) return;

    final selectedDate = _dateController.text.trim();
    final routeName = _routeNameController.text.trim();

    // 🔸 Validate route name
    if (routeName.isEmpty) {
      _showSnackBar("Please enter route name", color: Colors.redAccent);
      return;
    }

    // 🔸 Validate farmer selection
    if (_selectedFarmerIds.isEmpty) {
      _showSnackBar("Please select at least one farmer",
          color: Colors.redAccent);
      return;
    }

    setState(() => _isSubmitting = true); // 🔹 Start button loader

    try {
      // 🔹 Check if a plan already exists for the selected date
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

      // 🔹 Proceed with adding beat plan
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
      setState(() => _isSubmitting = false); // 🔹 Stop button loader
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerProvider = context.watch<GetMyFarmersProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),

          // 🔹 Top Bar
          Material(
            elevation: 3,
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
          ),

          // 🔹 Main Content
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
                            child: Text(
                              farmerProvider.errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          );
                        } else if (farmerProvider.farmers.isEmpty) {
                          return const Center(child: Text("No farmers found"));
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: farmerProvider.farmers.length,
                            itemBuilder: (context, index) {
                              final farmer = farmerProvider.farmers[index];
                              final isSelected =
                              _selectedFarmerIds.contains(farmer.id ?? "");

                              return Card(
                                margin:
                                const EdgeInsets.symmetric(vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 1,
                                child: CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (_) =>
                                      _toggleFarmerSelection(farmer.id ?? ""),
                                  title: Text(
                                    farmer.name ?? "Unknown Farmer",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
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

          // 🔹 Bottom Button
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  onPressed:
                  (_isSubmitting) ? null : _submitBeatPlan, // 🔹 disable
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
                      Text(
                        "Please wait...",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : const Text(
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
      ),
    );
  }
}
