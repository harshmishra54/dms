import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/give_points_farmer_model.dart';
import 'package:TrustTags_DMS/data/models/notify_farmer_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/add_farmer_points_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/notify_farmer_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/retarget_farmer_new_provider.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/provider/retarget_gap_farmer_provider.dart';
import 'package:TrustTags_DMS/data/models/retarget_gap_farmer_model.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RetargetFarmerScreen extends StatefulWidget {
  const RetargetFarmerScreen({Key? key}) : super(key: key);

  @override
  State<RetargetFarmerScreen> createState() => _RetargetFarmerScreenState();
}

class _RetargetFarmerScreenState extends State<RetargetFarmerScreen> with SingleTickerProviderStateMixin {
  String? userId;
  String? selectedDuration;
  final List<String> monthDurations = List.generate(11, (index) => "${index + 1} month");
  final List<String> yearDurations = ["1 year", "2 year", "3 year"];
  bool showGapFarmers = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final LinearGradient purpleGradient = const LinearGradient(
    colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Color primaryPurple = const Color(0xFF6A1B9A);
  final Color secondaryPurple = const Color(0xFFAB47BC);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = await SharedPrefsHelper.getUserId();
      if (id != null) {
        setState(() => userId = id);
        Provider.of<RetargetFarmerNewProvider>(context, listen: false).fetchRetargetFarmers(id);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchGapFarmers() {
    FocusScope.of(context).unfocus();

    if (userId == null || selectedDuration == null) {
      _showCustomSnackBar('Please select a duration.', isError: true);
      return;
    }

    final request = RetargetGapFarmerRequest(id: userId!, duration: selectedDuration!);
    Provider.of<RetargetGapFarmerProvider>(context, listen: false).fetchGapFarmers(request);
    setState(() => showGapFarmers = true);
    _animationController.forward();
  }

  void _showCustomSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: AutoTranslateText(message, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPointsDialog(List<Farmer> farmers) {
    final TextEditingController pointsController = TextEditingController();
    Set<String> tempSelectedIds = farmers.map((e) => e.farmerId).toSet();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: primaryPurple.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: purpleGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.loyalty, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: AutoTranslateText(
                          "Send Points",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryPurple.withOpacity(0.2), width: 1.5),
                          ),
                          child: TextField(
                            controller: pointsController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: "Enter Points",
                              labelStyle: TextStyle(color: primaryPurple.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.stars_rounded, color: primaryPurple, size: 24),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_rounded, color: primaryPurple, size: 22),
                                const SizedBox(width: 8),
                                const AutoTranslateText(
                                  "Select Farmers",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: purpleGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${tempSelectedIds.length}/${farmers.length}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: farmers.length,
                            separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              final farmer = farmers[index];
                              final isSelected = tempSelectedIds.contains(farmer.farmerId);
                              return InkWell(
                                onTap: () {
                                  setStateDialog(() {
                                    if (isSelected) {
                                      tempSelectedIds.remove(farmer.farmerId);
                                    } else {
                                      tempSelectedIds.add(farmer.farmerId);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: isSelected ? primaryPurple.withOpacity(0.05) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          gradient: isSelected ? purpleGradient : null,
                                          color: isSelected ? null : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: AutoTranslateText(
                                          farmer.farmerName,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primaryPurple, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: AutoTranslateText(
                            "Cancel",
                            style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: purpleGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (pointsController.text.isEmpty || tempSelectedIds.isEmpty) {
                                _showCustomSnackBar('Please enter points and select at least 1 farmer.', isError: true);
                                return;
                              }

                              final points = int.tryParse(pointsController.text);
                              if (points == null || points <= 0) {
                                _showCustomSnackBar('Enter valid points.', isError: true);
                                return;
                              }

                              final pointsProvider = Provider.of<AddFarmerPointsProvider>(context, listen: false);
                              final request = AddFarmerPointsRequest(ids: tempSelectedIds.toList(), points: points.toString());

                              await pointsProvider.addPoints(request);

                              if (pointsProvider.response != null) {
                                _showCustomSnackBar(pointsProvider.response!.message);
                              } else if (pointsProvider.error != null) {
                                _showCustomSnackBar(pointsProvider.error!, isError: true);
                              }

                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const AutoTranslateText(
                              "Send Points",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog(List<Farmer> farmers) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    Set<String> tempSelectedIds = farmers.map((e) => e.farmerId).toSet();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 650),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: primaryPurple.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: purpleGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: AutoTranslateText(
                          "Send Notification",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryPurple.withOpacity(0.2), width: 1.5),
                          ),
                          child: TextField(
                            controller: titleController,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: "Notification Title",
                              labelStyle: TextStyle(color: primaryPurple.withOpacity(0.7)),
                              prefixIcon: Icon(Icons.title_rounded, color: primaryPurple, size: 24),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryPurple.withOpacity(0.2), width: 1.5),
                          ),
                          child: TextField(
                            controller: messageController,
                            maxLines: 3,
                            style: const TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              labelText: "Message",
                              labelStyle: TextStyle(color: primaryPurple.withOpacity(0.7)),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Icon(Icons.message_rounded, color: primaryPurple, size: 24),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_rounded, color: primaryPurple, size: 22),
                                const SizedBox(width: 8),
                                const AutoTranslateText(
                                  "Select Farmers",
                                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: purpleGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${tempSelectedIds.length}/${farmers.length}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: farmers.length,
                            separatorBuilder: (_, __) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              final farmer = farmers[index];
                              final isSelected = tempSelectedIds.contains(farmer.farmerId);
                              return InkWell(
                                onTap: () {
                                  setStateDialog(() {
                                    if (isSelected) {
                                      tempSelectedIds.remove(farmer.farmerId);
                                    } else {
                                      tempSelectedIds.add(farmer.farmerId);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: isSelected ? primaryPurple.withOpacity(0.05) : Colors.transparent,
                                  child: Row(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          gradient: isSelected ? purpleGradient : null,
                                          color: isSelected ? null : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? Colors.transparent : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: isSelected
                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: AutoTranslateText(
                                          farmer.farmerName,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: primaryPurple, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: AutoTranslateText(
                            "Cancel",
                            style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: purpleGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (titleController.text.isEmpty ||
                                  messageController.text.isEmpty ||
                                  tempSelectedIds.isEmpty) {
                                _showCustomSnackBar(
                                  'Please fill all fields and select at least 1 farmer.',
                                  isError: true,
                                );
                                return;
                              }

                              final notifyProvider = Provider.of<NotifyFarmer>(context, listen: false);
                              final request = NotificationRequest(
                                ids: tempSelectedIds.toList(),
                                title: titleController.text,
                                message: messageController.text,
                              );

                              await notifyProvider.sendNotification(request);

                              if (notifyProvider.response != null) {
                                _showCustomSnackBar(notifyProvider.response!.message);
                              } else if (notifyProvider.error != null) {
                                _showCustomSnackBar(notifyProvider.error!, isError: true);
                              }

                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const AutoTranslateText(
                              "Send",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDurations = [...monthDurations, ...yearDurations];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Retarget Farmers',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.black),
                        onPressed: () {
                          List<Farmer> farmerList = [];
                          if (showGapFarmers) {
                            final gapProvider = Provider.of<RetargetGapFarmerProvider>(context, listen: false);
                            if (gapProvider.response?.data.isNotEmpty ?? false) {
                              farmerList = gapProvider.response!.data;
                            }
                          } else {
                            final masterProvider = Provider.of<RetargetFarmerNewProvider>(context, listen: false);
                            if (masterProvider.farmers.isNotEmpty) {
                              farmerList = masterProvider.farmers
                                  .map((f) => Farmer(farmerId: f.farmerId, farmerName: f.farmerName))
                                  .toList();
                            }
                          }

                          if (farmerList.isNotEmpty) {
                            _showNotificationDialog(farmerList);
                          } else {
                            _showCustomSnackBar('No farmers available to notify.', isError: true);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.loyalty, color: Colors.black),
                        onPressed: () {
                          List<Farmer> farmerList = [];
                          if (showGapFarmers) {
                            final gapProvider = Provider.of<RetargetGapFarmerProvider>(context, listen: false);
                            if (gapProvider.response?.data.isNotEmpty ?? false) {
                              farmerList = gapProvider.response!.data;
                            }
                          } else {
                            final masterProvider = Provider.of<RetargetFarmerNewProvider>(context, listen: false);
                            if (masterProvider.farmers.isNotEmpty) {
                              farmerList = masterProvider.farmers
                                  .map((f) => Farmer(farmerId: f.farmerId, farmerName: f.farmerName))
                                  .toList();
                            }
                          }

                          if (farmerList.isNotEmpty) {
                            _showPointsDialog(farmerList);
                          } else {
                            _showCustomSnackBar('No farmers available to send points.', isError: true);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: purpleGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        AutoTranslateText(
                          "Filter by Gap Duration",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryPurple.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primaryPurple.withOpacity(0.15), width: 1.5),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                hintText: "Select Duration",
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                border: InputBorder.none,
                                prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                              ),
                              dropdownColor: Colors.white,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryPurple),
                              value: selectedDuration,
                              items: allDurations.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: AutoTranslateText(
                                    e,
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => selectedDuration = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: purpleGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primaryPurple.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _fetchGapFarmers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.all(16),
                              elevation: 0,
                              minimumSize: const Size(56, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFarmerList(
                  title: "All Farmers (Master List)",
                  icon: Icons.group_rounded,
                  builder: (context) => Consumer<RetargetFarmerNewProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return _buildLoadingState();
                      }
                      if (provider.error != null) {
                        return _buildErrorState(provider.error!);
                      }
                      if (provider.farmers.isEmpty) {
                        return _buildEmptyState("No farmers found.");
                      }
                      return Column(
                        children: provider.farmers
                            .map((farmer) => _buildFarmerTile(
                          farmerName: farmer.farmerName,
                          farmerId: farmer.farmerId,
                          iconColor: secondaryPurple,
                        ))
                            .toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                if (showGapFarmers)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFarmerList(
                      title: "Targeted Farmers (Gap: $selectedDuration)",
                      icon: Icons.group_add,
                      builder: (context) => Consumer<RetargetGapFarmerProvider>(
                        builder: (context, provider, _) {
                          if (provider.loading) {
                            return _buildLoadingState();
                          }
                          if (provider.error != null) {
                            return _buildErrorState(provider.error!);
                          }
                          if (provider.response?.data.isEmpty != false) {
                            return _buildEmptyState("No targeted farmers found for this duration.");
                          }
                          return Column(
                            children: provider.response!.data
                                .map((farmer) => _buildFarmerTile(
                              farmerName: farmer.farmerName,
                              farmerId: farmer.farmerId,
                              iconColor: primaryPurple,
                              isHighlighted: true,
                            ))
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerList({
    required String title,
    required IconData icon,
    required WidgetBuilder builder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple.withOpacity(0.1), primaryPurple.withOpacity(0.05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: AutoTranslateText(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryPurple,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        builder(context),
      ],
    );
  }

  Widget _buildFarmerTile({
    required String farmerName,
    required String farmerId,
    required Color iconColor,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: iconColor.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? iconColor.withOpacity(0.15)
                : Colors.black.withOpacity(0.04),
            blurRadius: isHighlighted ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isHighlighted
                        ? purpleGradient
                        : LinearGradient(
                      colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: isHighlighted ? Colors.white : iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AutoTranslateText(
                    farmerName,
                    style: TextStyle(
                      fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: purpleGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: primaryPurple,
                strokeWidth: 3.5,
              ),
            ),
            const SizedBox(height: 16),
            AutoTranslateText(
              'Loading...',
              style: TextStyle(color: primaryPurple, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 36),
          ),
          const SizedBox(height: 16),
          const AutoTranslateText(
            'Failed to load data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          AutoTranslateText(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_rounded, color: Colors.grey.shade400, size: 48),
          ),
          const SizedBox(height: 20),
          AutoTranslateText(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}