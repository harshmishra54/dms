import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_history_screen.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/returns/distributor/return_order_tab.dart';
import 'package:TrustTags_DMS/features/rewards/reward_claim_history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/home/presentation/history_screen.dart';
import '../../features/home/presentation/profile_screen.dart';
import '../app_colors.dart';

class CustomDrawerModal extends StatefulWidget {
  final VoidCallback onLogout;

  const CustomDrawerModal({super.key, required this.onLogout});

  @override
  State<CustomDrawerModal> createState() => _CustomDrawerModalState();
}

class _CustomDrawerModalState extends State<CustomDrawerModal>
    with SingleTickerProviderStateMixin {
  String userName = 'Guest User';

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserName();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final name = await SharedPrefsHelper.getUserName();
    if (mounted && name != null && name.isNotEmpty) {
      setState(() => userName = name);
    }
  }

  Future<void> _confirmLogout() async {
    final logoutProvider = Provider.of<LogoutProvider>(context, listen: false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
                  onPressed:
                  provider.isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    await provider.logout();

                    if (provider.logoutResponse != null) {
                      await SharedPrefsHelper.clearAll();

                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LandingScreen()),
                              (route) => false,
                        );
                      }
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
                      : const Text("Yes"),
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
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ Combined Row (Close Icon + Avatar + Name)
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
                              child: Text('Menu',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            _drawerItem(context, Icons.shopping_cart, 'My Orders', const DistributorHistoryScreen()),
                            _drawerItem(context, Icons.assignment_return,
                                'Return Orders', const ReturnOrderTab()),
                            _drawerItem(context, Icons.history, 'History',
                                const HistoryScreen()),
                            _drawerItem(
                                context,
                                Icons.card_giftcard_sharp,
                                'Reward Claim History',
                                const RewardClaimHistoryScreen()),
                            _drawerItem(context, Icons.menu_book, 'Catalogue',
                                const HistoryScreen(initialTab: 1)),

                            const Divider(height: 32),

                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Text('Account',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            _drawerItem(context, Icons.person_outline,
                                'Profile', const ProfileScreen()),

                            const Divider(height: 32),

                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child:
                              Text('About', style: TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.logout,
                                  color: Colors.black),
                              title: const Text('Log Out'),
                              onTap: _confirmLogout,
                            ),

                            const Divider(height: 32),

                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child:
                              Text('v 1.0.4', style: TextStyle(fontSize: 14)),
                            ),
                            const SizedBox(height: 20),
                            const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Text('© 2020 - 2025',
                                  style: TextStyle(fontSize: 14)),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
