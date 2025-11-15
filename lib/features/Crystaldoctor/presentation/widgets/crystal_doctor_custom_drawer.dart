
import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
// import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_meeting_history_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/doctor_history_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/farmer_details_and_location.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/farmer_list_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/meeting_qr_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/route_by_pincode_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/targetfarmer.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/punch_out.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/Leave_Management.dart';
import 'package:TrustTags_DMS/features/salesDashboard/meeting_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import '../../../../common/app_colors.dart';

class CrystalDoctorCustomDrawer extends StatefulWidget {
  const CrystalDoctorCustomDrawer({super.key});

  @override
  State<CrystalDoctorCustomDrawer> createState() => _CrystalDoctorCustomDrawerState();
}

class _CrystalDoctorCustomDrawerState extends State<CrystalDoctorCustomDrawer> {
  String userName = "Guest User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
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
                  onPressed:
                  provider.isLoading ? null : () => Navigator.of(ctx).pop(),
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
                        MaterialPageRoute(
                            builder: (_) => const LandingScreen()),
                            (route) => false,
                      );
                    } else if (provider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(provider.errorMessage!)),
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


  /// Order History Tap Logic

  /// Meeting History Tap Logic


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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const ProfileScreen(),
                                        ),
                                      );
                                    },
                                    child: const CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.topBarColor,
                                      child: Icon(Icons.person,
                                          size: 32, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                          _drawerItem(context, Icons.location_on, 'Farmer Location', const PhoneLocationScreen()),
                          _drawerItem(context, Icons.agriculture, 'Farmers Details', const FarmerListScreen()),
                          /// 👇 Show Approve Distributor only for roleId 1
                          _drawerItem(context, Icons.card_travel, 'Meeting History', const MeetingHistory()),
                          _drawerItem(context, Icons.recommend, 'Recommendation History', const DoctorHistoryScreen()),
                          _drawerItem(context, Icons.qr_code, 'View Meeting QR', const MeetingQrScreen()),
                          _drawerItem(context, Icons.analytics, 'Farmer Analytics', const RetargetFarmerScreen()),
                          _drawerItem(context, Icons.timer_off, 'Punch Out', PunchOut()),
                          _drawerItem(context, Icons.leave_bags_at_home, 'Leave Management', LeaveScreen()),






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
                            child: AutoTranslateText('© 2020 - 2025', style: TextStyle(fontSize: 14)),
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
