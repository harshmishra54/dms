import 'dart:convert';
import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/data/models/get_tsi_list_for_rsm_model.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/meeting_qr_screen.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/orders/presentation/my_screen.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/punch_out.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/my_leave_screen_list.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Retailer_approval.dart';
import 'package:TrustTags_DMS/features/salesDashboard/distributor_approval.dart';
import 'package:TrustTags_DMS/features/salesDashboard/meeting_history.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/tsi_list_for_rsm_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/demand_prediction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import '../../../../common/app_colors.dart';

class SalesCustomDrawer extends StatefulWidget {
  const SalesCustomDrawer({super.key});

  @override
  State<SalesCustomDrawer> createState() => _SalesCustomDrawerState();
}

class _SalesCustomDrawerState extends State<SalesCustomDrawer> {
  String userName = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      await profileProvider.fetchCustomerDetails("");
    });
  }


  Future<void> _loadUserName() async {
    final name = await SharedPrefsHelper.getUserName();
    if (mounted) {
      setState(() {
        userName = name?.isNotEmpty == true ? name! : "Guest User";
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final logoutProvider = Provider.of<LogoutProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer<LogoutProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              title: const Text("Logout"),
              content: provider.isLoading
                  ? Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Logging out..."),
                ],
              )
                  : const Text("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  onPressed: provider.isLoading ? null : () => Navigator.of(ctx).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    await provider.logout();
                    if (provider.logoutResponse != null) {
                      await SharedPrefsHelper.clearAll();
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LandingScreen()),
                            (route) => false,
                      );
                    } else if (provider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage!)),
                      );
                    }
                  },
                  child: provider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text("Yes, Logout"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Reusable TSI selection dialog
  Future<TsiUser?> _selectTsi(String userId) async {
    final provider = TsiListProvider();
    await provider.fetchTsiList(userId);

    if (provider.tsiUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No TSI found for your account")),
      );
      return null;
    }

    final selectedTsi = await showDialog<TsiUser>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select TSI"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.tsiUsers.length,
              itemBuilder: (context, index) {
                final tsi = provider.tsiUsers[index];
                return ListTile(
                  title: Text(tsi.name ?? "Unnamed TSI"),
                  onTap: () => Navigator.pop(context, tsi),
                );
              },
            ),
          ),
        );
      },
    );

    return selectedTsi;
  }

  /// Order History Tap Logic
  Future<void> _onOrderHistoryTap(BuildContext context) async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    if (roleId == 19 && userId != null) {
      final selectedTsi = await _selectTsi(userId);
      if (selectedTsi != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyScreen(tsiId: selectedTsi.id),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyScreen()),
      );
    }
  }

  /// Meeting History Tap Logic
  Future<void> _onMeetingHistoryTap(BuildContext context) async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    if (roleId == 19 && userId != null) {
      final selectedTsi = await _selectTsi(userId);
      if (selectedTsi != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingHistory(tsiId: selectedTsi.id),
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MeetingHistory()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const bottomNavHeight = 70.0;

    return FutureBuilder<int?>(
      future: SharedPrefsHelper.getRoleId(),
      builder: (context, snapshot) {
        final roleId = snapshot.data;

        return SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: screenHeight - bottomNavHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🔹 Header row with avatar, username & close button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                      );
                                    },
                                    child: Consumer<ProfileProvider>(
                                      builder: (context, profileProvider, _) {
                                        final imageUrl = profileProvider.decryptedCustomerData?.profilepicture;
                                        final hasImage = imageUrl != null && imageUrl.isNotEmpty;

                                        return CircleAvatar(
                                          radius: 28,
                                          backgroundColor: AppColors.topBarColor,
                                          backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
                                          child: hasImage
                                              ? null
                                              : const Icon(Icons.person, size: 32, color: Colors.white),
                                        );
                                      },
                                    ),

                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      userName,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 26),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),

                          const Divider(height: 32),
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('Menu', style: TextStyle(fontSize: 16)),
                          ),

                          _drawerItem(context, Icons.dashboard, 'Dashboard', SalesDashboardScreen()),
                          _drawerItem(context, Icons.timer_off, 'Punch Out', PunchOut()),

                          _drawerItem(context, Icons.qr_code, 'View Meeting QR', const MeetingQrScreen()),
                          _drawerItem(context, Icons.qr_code, 'Demand Prediction', const FarmerDemandDashboard()),


                          ListTile(
                            leading: const Icon(Icons.shopping_cart, color: Colors.black),
                            title: const Text('Order History', style: TextStyle(fontSize: 15)),
                            onTap: () => _onOrderHistoryTap(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.meeting_room_outlined, color: Colors.black),
                            title: const Text('Meeting History', style: TextStyle(fontSize: 15)),
                            onTap: () => _onMeetingHistoryTap(context),
                          ),

                          if (roleId == 19)
                            ListTile(
                              leading: const Icon(Icons.verified_user, color: Colors.black),
                              title: const Text('Approve Distributor', style: TextStyle(fontSize: 15)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DistributorApprovalListScreen()));
                              },
                            ),
                          if (roleId == 19)
                            ListTile(
                              leading: const Icon(Icons.verified_user, color: Colors.black),
                              title: const Text('Approve Retailer', style: TextStyle(fontSize: 15)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RetailerApprovalScren()));
                              },
                            ),
                          if (roleId == 19)
                            ListTile(
                              leading: const Icon(Icons.work_off, color: Colors.black),
                              title: const Text('Approve Leaves', style: TextStyle(fontSize: 15)),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MyLeaveScreen()));
                              },
                            ),

                          const Divider(height: 32),
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('Account', style: TextStyle(fontSize: 16)),
                          ),

                          _drawerItem(context, Icons.person_outline, 'Profile', const ProfileScreen()),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.black),
                            title: const Text('Logout'),
                            onTap: () => _handleLogout(context),
                          ),

                          const Divider(height: 32),
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text('v 1.0.4', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Text('© 2020 - 2025', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
