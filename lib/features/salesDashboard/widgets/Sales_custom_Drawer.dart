
import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/core/permissions/feature_access.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/fill_details_form.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/doctor_history_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/farmer_details_and_location.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/farmer_list_screen.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/widgets/meeting_qr_screen.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/orders/presentation/my_screen.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/punch_out.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Leave/my_leave_screen_list.dart';
import 'package:TrustTags_DMS/features/salesDashboard/ProductDemo/Presentation/demo_history_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Retailer_approval.dart';
import 'package:TrustTags_DMS/features/salesDashboard/distributor_approval.dart';
import 'package:TrustTags_DMS/features/salesDashboard/meeting_history.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/get_childs_provider.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/widgets/whatsapp_product_demo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;

import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import '../../../../common/app_colors.dart';

class SalesCustomDrawer extends ConsumerStatefulWidget
 {
  const SalesCustomDrawer({super.key});

  @override
  ConsumerState<SalesCustomDrawer> createState() =>
      _SalesCustomDrawerState();

 }

class _SalesCustomDrawerState extends ConsumerState<SalesCustomDrawer>
 {
  String userName = "Guest User";




  @override
  void initState() {
    super.initState();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await SharedPrefsHelper.getUserId();
      if (userId != null) {
        ref.read(getChildsProvider.notifier).fetchChilds(id: userId);
      }

      final profileProvider =
      legacy.Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.fetchCustomerDetails("");
    });
  }


  bool canView(FeatureAccess feature) {
    final notifier = ref.read(permissionsProvider.notifier);
    return notifier.hasPermission(feature, view: true);
  }


  void safePop(BuildContext ctx) {
    if (Navigator.canPop(ctx)) {
      Navigator.pop(ctx);
    }
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
    final logoutProvider = legacy.Provider.of<LogoutProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return legacy.Consumer<LogoutProvider>(
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
  void _navigateAfterClose(Widget page) {
    Future.microtask(() {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  Future<void> _handleSelfOrChildNavigation({
    required BuildContext context,
    required FeatureAccess selfFeature,
    required FeatureAccess childFeature,
    required Widget Function({String? childId}) onNavigate,
  }) async {
    final state = ref.read(getChildsProvider);

    state.when(
      loading: () {},
      error: (e, _) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      },
      data: (childs) {
        // 🔹 NO CHILDS → SELF
        if (childs.isEmpty) {
          if (!canView(selfFeature)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You don't have permission to access this"),
              ),
            );
            return;
          }

          safePop(context); // close drawer IF open
          _navigateAfterClose(onNavigate());
          return;
        }

        // 🔹 CHILDS EXIST
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (sheetContext) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // SELF
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Self"),
                    onTap: () {
                      Navigator.pop(sheetContext); // close sheet
                      safePop(context);            // close drawer ONLY if exists

                      if (!canView(selfFeature)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("You don't have permission to access this"),
                          ),
                        );
                        return;
                      }

                      _navigateAfterClose(onNavigate());
                    },
                  ),

                  const Divider(),

                  // CHILDS
                  ...childs.map(
                        (child) => ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(child.name),
                      onTap: () {
                        Navigator.pop(sheetContext); // close sheet
                        safePop(context);            // safe drawer pop

                        if (!canView(childFeature)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("You don't have permission to access this"),
                            ),
                          );
                          return;
                        }

                        _navigateAfterClose(
                          onNavigate(childId: child.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const bottomNavHeight = 70.0;
    final childsState = ref.watch(getChildsProvider);

    final bool hasChilds = childsState.maybeWhen(
      data: (childs) => childs.isNotEmpty,
      orElse: () => false,
    );

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
                                    child: legacy.Consumer<ProfileProvider>(
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

                          // _drawerItem(context, Icons.qr_code, 'View Meeting QR', const MeetingQrScreen()),
                          if (canView(FeatureAccess.meeting))
                            ListTile(
                              leading: const Icon(Icons.qr_code),
                              title: const Text('View Meeting QR'),
                              onTap: () {
                                Navigator.pop(context);

                                // ✅ SELF ONLY — no child logic
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MeetingQrScreen(),
                                  ),
                                );
                              },
                            ),


                          if (canView(FeatureAccess.orderHistory))
                            ListTile(
                              leading: const Icon(Icons.shopping_cart),
                              title: const Text(
                                'Order History',
                                style: TextStyle(fontSize: 15),
                              ),
                                onTap: () async {
                                  await _handleSelfOrChildNavigation(
                                    context: context,
                                    selfFeature: FeatureAccess.orderHistory,
                                    childFeature: FeatureAccess.orderHistory,
                                    onNavigate: ({String? childId}) {
                                      return MyScreen(tsiId: childId);
                                    },
                                  );
                                }


                            ),


                          if (canView(FeatureAccess.meeting))
                            ListTile(
                              leading: const Icon(Icons.meeting_room_outlined),
                              title: const Text('Meeting History'),
                              onTap: () async {
                                await _handleSelfOrChildNavigation(
                                  context: context,
                                  selfFeature: FeatureAccess.meeting,
                                  childFeature: FeatureAccess.meeting,
                                  onNavigate: ({String? childId}) {
                                    return MeetingHistory(tsiId: childId);
                                  },
                                );
                              },
                            ),



                          if (hasChilds)
                            ListTile(
                              leading: const Icon(Icons.verified_user, color: Colors.black),
                              title: const Text(
                                'Approve Distributor',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DistributorApprovalListScreen(),
                                  ),
                                );
                              },
                            ),

                          if (hasChilds)
                            ListTile(
                              leading: const Icon(Icons.verified_user, color: Colors.black),
                              title: const Text(
                                'Approve Retailer',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RetailerApprovalScren(),
                                  ),
                                );
                              },
                            ),

                          if (hasChilds)
                            ListTile(
                              leading: const Icon(Icons.work_off, color: Colors.black),
                              title: const Text(
                                'Approve Leaves',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MyLeaveScreen(),
                                  ),
                                );
                              },
                            ),

                          const Divider(height: 32),
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Text('Farmer', style: TextStyle(fontSize: 16)),
                          ),
                          if (canView(FeatureAccess.registerFarmer))
                            ListTile(
                              leading: const Icon(Icons.location_on, color: Colors.black),
                              title: const Text(
                                'Farmer Onboarding',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const FillDetailsForm(),
                                  ),
                                );
                              },
                            ),


                          _drawerItem(context, Icons.location_on, 'Farmer Location', const PhoneLocationScreen()),
                          _drawerItem(context, Icons.agriculture, 'Farmers Details', const FarmerListScreen()),
                          /// 👇 Show Approve Distributor only for roleId 1

                          // _drawerItem(context, Icons.recommend, 'Recommendation History', const DoctorHistoryScreen()),
                          if (canView(FeatureAccess.productRecommendation))
                            ListTile(
                              leading: const Icon(Icons.recommend, color: Colors.black),
                              title: const Text(
                                'Recommendation History',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DoctorHistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          if (canView(FeatureAccess.planProductDemo))
                            ListTile(
                              leading: const Icon(Icons.next_plan_outlined, color: Colors.black),
                              title: const Text(
                                'Plan Demo',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DemoWhatsappScreen(),
                                  ),
                                );
                              },
                            ),

                          if (canView(FeatureAccess.planProductDemo))
                            ListTile(
                              leading: const Icon(Icons.next_plan_outlined, color: Colors.black),
                              title: const Text(
                                'Demo History',
                                style: TextStyle(fontSize: 15),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DemoHistoryScreen(),
                                  ),
                                );
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
