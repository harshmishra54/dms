import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/dashboard/widgets/product_catalogue_screen.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/invite_earn_screen.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/recommended_product_by_advisor.dart';
import 'package:TrustTags_DMS/features/spinner/presentation/spinner_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/home/presentation/profile_screen.dart';
import 'package:TrustTags_DMS/features/rewards/reward_claim_history.dart';
import 'package:TrustTags_DMS/features/home/presentation/history_screen.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class FarmerCustomDrawer extends StatefulWidget {
  final VoidCallback onLogout;

  const FarmerCustomDrawer({super.key, required this.onLogout});

  @override
  State<FarmerCustomDrawer> createState() => _FarmerCustomDrawerState();
}

class _FarmerCustomDrawerState extends State<FarmerCustomDrawer> {
  String _userName = "Guest User";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false)
          .fetchCustomerDetails(""); // pass token if required
    });
  }




  /// ✅ Logout Confirmation + API call
  Future<void> _confirmLogout(BuildContext context) async {
    final logoutProvider = Provider.of<LogoutProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Consumer<LogoutProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              title: const Text("Confirm Logout"),
              content: provider.isLoading
                  ? Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text("Logging out..."),
                ],
              )
                  : const Text("Are you sure you want to log out?"),
              actions: [
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () => Navigator.of(ctx).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    // Trigger logout API
                    await provider.logout();

                    if (provider.logoutResponse != null) {
                      // Clear prefs only if logout succeeds
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const bottomNavHeight = 70.0;

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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                                child: Consumer<ProfileProvider>(
                                  builder: (context, profileProvider, _) {
                                    final imageUrl = profileProvider
                                        .decryptedCustomerData?.profilepicture;

                                    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

                                    return CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.topBarColor,
                                      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
                                      child: hasImage
                                          ? null
                                          : const Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),

                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width:
                                MediaQuery.of(context).size.width * 0.4,
                                child: Consumer<ProfileProvider>(
                                  builder: (context, profile, _) {
                                    final name = profile.decryptedCustomerData?.name ?? "Guest User";

                                    return Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    );
                                  },
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
                      _drawerItem(context, Icons.history, 'History',
                          const HistoryScreen()),
                      _drawerItem(
                          context,
                          Icons.card_giftcard_sharp,
                          'Reward Claim History',
                          const RewardClaimHistoryScreen()),
                      _drawerItem(
                          context,
                          Icons.move_to_inbox,
                          'Catalogue',
                          const ProductCatalogueScreen()),
                      // _drawerItem(context, Icons.menu_book, 'Catalogue',
                      //     const HistoryScreen(initialTab: 1)),
                      _drawerItem(
                          context,
                          Icons.production_quantity_limits,
                          'Product Recommendation',
                          const RecommendedProductsScreen()),
                      // _drawerItem(
                      //     context,
                      //     Icons.card_giftcard_sharp,
                      //     'Spinner History',
                      //     const SpinnerHistoryScreen()),

                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('Account', style: TextStyle(fontSize: 16)),
                      ),
                      _drawerItem(context, Icons.person_outline, 'Profile',
                          const ProfileScreen()),
                      _drawerItem(context, Icons.insert_invitation_outlined, 'Invite and Earn',
                          InviteEarnScreen()),

                      const Divider(height: 32),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('About', style: TextStyle(fontSize: 16)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.black),
                        title: const Text('LogOut'),
                        onTap: () => _confirmLogout(context),
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

  static Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget? destination) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: () {
        Navigator.pop(context);
        if (destination != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
