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

class _RetargetFarmerScreenState extends State<RetargetFarmerScreen> {
  String? userId;
  String? selectedDuration;
  final List<String> monthDurations =
  List.generate(11, (index) => "${index + 1} month");
  final List<String> yearDurations = ["1 year", "2 year", "3 year"];
  bool showGapFarmers = false;

  final LinearGradient purpleGradient = const LinearGradient(
    colors: [
      Color(0xFF6A1B9A),
      Color(0xFFAB47BC),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Color primaryPurple = const Color(0xFF6A1B9A);
  final Color secondaryPurple = const Color(0xFFAB47BC);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = await SharedPrefsHelper.getUserId();
      if (id != null) {
        setState(() => userId = id);
        Provider.of<RetargetFarmerNewProvider>(context, listen: false)
            .fetchRetargetFarmers(id);
      }
    });
  }

  void _fetchGapFarmers() {
    FocusScope.of(context).unfocus();

    if (userId == null || selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const AutoTranslateText('Please select a duration.'),
          backgroundColor: primaryPurple,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final request = RetargetGapFarmerRequest(
      id: userId!,
      duration: selectedDuration!,
    );

    Provider.of<RetargetGapFarmerProvider>(context, listen: false)
        .fetchGapFarmers(request);
    setState(() => showGapFarmers = true);
  }
  void _showPointsDialog(List<Farmer> farmers) {
    final TextEditingController pointsController = TextEditingController();
    Set<String> tempSelectedIds = farmers.map((e) => e.farmerId).toSet();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const AutoTranslateText("Send Points"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Points",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AutoTranslateText("Select Farmers:"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: farmers.map((farmer) {
                        return CheckboxListTile(
                          value: tempSelectedIds.contains(farmer.farmerId),
                          title: AutoTranslateText(farmer.farmerName),
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                tempSelectedIds.add(farmer.farmerId);
                              } else {
                                tempSelectedIds.remove(farmer.farmerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const AutoTranslateText("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                onPressed: () async {
                  if (pointsController.text.isEmpty || tempSelectedIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const AutoTranslateText(
                            'Please enter points and select at least 1 farmer.'),
                        backgroundColor: primaryPurple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  final points = int.tryParse(pointsController.text);
                  if (points == null || points <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const AutoTranslateText('Enter valid points.'),
                        backgroundColor: primaryPurple,
                      ),
                    );
                    return;
                  }

                  // Use your provider to send points
                  final pointsProvider =
                  Provider.of<AddFarmerPointsProvider>(context, listen: false);
                  final request = AddFarmerPointsRequest(
                    ids: tempSelectedIds.toList(),
                    points: points.toString()
                  );

                  await pointsProvider.addPoints(request);

                  if (pointsProvider.response != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(pointsProvider.response!.message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (pointsProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(pointsProvider.error!),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  Navigator.pop(ctx);
                },
                child: const AutoTranslateText("Send"),
              ),
            ],
          );
        });
      },
    );
  }


  void _showNotificationDialog(List<Farmer> farmers) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    Set<String> tempSelectedIds = farmers.map((e) => e.farmerId).toSet();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          return AlertDialog(
            title: const AutoTranslateText("Send Notification"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: "Message",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AutoTranslateText("Select Farmers:"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView(
                      children: farmers.map((farmer) {
                        return CheckboxListTile(
                          value: tempSelectedIds.contains(farmer.farmerId),
                          title: AutoTranslateText(farmer.farmerName),
                          onChanged: (val) {
                            setStateDialog(() {
                              if (val == true) {
                                tempSelectedIds.add(farmer.farmerId);
                              } else {
                                tempSelectedIds.remove(farmer.farmerId);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const AutoTranslateText("Cancel"),
              ),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      messageController.text.isEmpty ||
                      tempSelectedIds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const AutoTranslateText(
                            'Please fill all fields and select at least 1 farmer.'),
                        backgroundColor: primaryPurple,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  final notifyProvider =
                  Provider.of<NotifyFarmer>(context, listen: false);
                  final request = NotificationRequest(
                    ids: tempSelectedIds.toList(),
                    title: titleController.text,
                    message: messageController.text,
                  );

                  await notifyProvider.sendNotification(request);

                  if (notifyProvider.response != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notifyProvider.response!.message),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (notifyProvider.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(notifyProvider.error!),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }

                  Navigator.pop(ctx);
                },
                child: const AutoTranslateText("Send"),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDurations = [...monthDurations, ...yearDurations];

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications, color: Colors.black),
                        onPressed: () {
                          // your existing _showNotificationDialog logic
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const AutoTranslateText('No farmers available to notify.'),
                                backgroundColor: primaryPurple,
                              ),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.loyalty, color: Colors.black),
                        onPressed: () {
                          // your _showPointsDialog logic
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const AutoTranslateText('No farmers available to send points.'),
                                backgroundColor: primaryPurple,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Duration Selector Card ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              shadowColor: primaryPurple.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: AutoTranslateText(
                        "Filter Gap:",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Select Duration",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                            BorderSide(color: secondaryPurple, width: 2),
                          ),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: primaryPurple),
                        value: selectedDuration,
                        items: allDurations.map((e) {
                          return DropdownMenuItem(
                              value: e,
                              child: AutoTranslateText(e,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedDuration = val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        gradient: purpleGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ElevatedButton(
                        onPressed: _fetchGapFarmers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          elevation: 0,
                          minimumSize: const Size(0, 48),
                        ),
                        child: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Farmer Lists ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildFarmerList(
                  title: "All Farmers (Master List):",
                  builder: (context) =>
                      Consumer<RetargetFarmerNewProvider>(
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
                const SizedBox(height: 25),
                if (showGapFarmers)
                  _buildFarmerList(
                    title: "Targeted Farmers (Gap: $selectedDuration):",
                    builder: (context) =>
                        Consumer<RetargetGapFarmerProvider>(
                          builder: (context, provider, _) {
                            if (provider.loading) {
                              return _buildLoadingState();
                            }
                            if (provider.error != null) {
                              return _buildErrorState(provider.error!);
                            }
                            if (provider.response?.data.isEmpty != false) {
                              return _buildEmptyState(
                                  "No targeted farmers found for this duration.");
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerList(
      {required String title, required WidgetBuilder builder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AutoTranslateText(
            title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: primaryPurple),
          ),
        ),
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
    return Card(
      elevation: isHighlighted ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isHighlighted
            ? BorderSide(color: iconColor.withOpacity(0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: () {},
        splashColor: iconColor.withOpacity(0.1),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.15),
          child: Icon(Icons.person, color: iconColor, size: 24),
        ),
        title: AutoTranslateText(
          farmerName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: primaryPurple),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
        child: Padding(
            padding: const EdgeInsets.all(30),
            child: CircularProgressIndicator(color: primaryPurple)));
  }

  Widget _buildErrorState(String error) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              AutoTranslateText('Failed to load data: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
        ));
  }

  Widget _buildEmptyState(String message) {
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey, size: 40),
              const SizedBox(height: 10),
              AutoTranslateText(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ));
  }
}
