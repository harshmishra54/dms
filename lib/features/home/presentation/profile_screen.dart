import 'package:TrustTags_DMS/common/provider/logout_provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/authentication/provider/profile_provider.dart';
import 'package:TrustTags_DMS/features/landing/presentation/landing_screen.dart';
import 'package:TrustTags_DMS/features/profile/presentation/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/features/faqs/presentation/faqs_screen.dart';

import '../../../common/app_colors.dart';
import '../../../common/utils/email_launcher.dart';
import '../../../common/utils/phone_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasFetched = false;

  Future<void> _showLogoutDialog(BuildContext context) async {
    showDialog(
      barrierDismissible: false, // prevent closing while loading
      context: context,
      builder: (BuildContext context) {
        return Consumer<LogoutProvider>(
          builder: (context, logoutProvider, _) {
            bool isLoading = logoutProvider.isLoading;

            return AlertDialog(
              title: const AutoTranslateText("Logout"),
              content: isLoading
                  ? Row(
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  AutoTranslateText("Logging out..."),
                ],
              )
                  : const AutoTranslateText("Are you sure you want to logout?"),
              actions: [
                TextButton(
                  child: const AutoTranslateText("Cancel"),
                  onPressed: isLoading
                      ? null
                      : () {
                    Navigator.of(context).pop(); // close dialog
                  },
                ),
                TextButton(
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const AutoTranslateText("Yes"),
                  onPressed: isLoading
                      ? null
                      : () async {
                    await logoutProvider.logout();

                    if (logoutProvider.logoutResponse != null) {
                      // ✅ Clear shared prefs (optional, already done in provider)
                      await SharedPrefsHelper.clearAll();

                      // ✅ Navigate to LandingScreen
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LandingScreen()),
                              (Route<dynamic> route) => false,
                        );
                      }
                    } else if (logoutProvider.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: AutoTranslateText(logoutProvider.errorMessage!),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchCustomerDataOnce();

    // ✅ Set status bar color to match custom app bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.topBarColor, // your color
        statusBarIconBrightness: Brightness.light, // white icons
      ),
    );
  }

  /// Fetch customer details only once
  Future<void> _fetchCustomerDataOnce() async {
    if (_hasFetched) return;
    _hasFetched = true;

    final token = await SharedPrefsHelper.getAccessToken() ?? '';
    if (!mounted) return;

    await Provider.of<ProfileProvider>(context, listen: false)
        .fetchCustomerDetails(token);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    final isLoading = provider.isLoading;
    final error = provider.errorMessage;

    // decryptedCustomerData is of type CustomerData? (set in provider)
    final customer = provider.decryptedCustomerData;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Custom "App Bar" Container
          const AppStatusBar(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: const AutoTranslateText(
              "Profile",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 🔽 Body Content
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: AutoTranslateText(error))
                : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- Profile Card ---
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.topBarColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.topBarColor, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              AutoTranslateText(
                                customer?.name ?? 'No Name',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,                  // limits to one line
                                overflow: TextOverflow.ellipsis, // adds "..." if overflow
                              ),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const UserProfileScreen(),
                                    ),
                                  );
                                },
                                child: const AutoTranslateText(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    decoration:
                                    TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: customer?.profilepicture != null &&
                                        customer!.profilepicture!.isNotEmpty
                                        ? Image.network(
                                      customer.profilepicture!,        // backend image
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/crystal_logo.jpeg', // fallback (same as before)
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    )
                                        : Image.asset(
                                      'assets/images/crystal_logo.jpeg',   // default logo
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  const SizedBox(height: 6),
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.topBarColor,
                                      borderRadius:
                                      BorderRadius.circular(20),
                                    ),
                                    child: const AutoTranslateText(
                                      'Verified',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const AutoTranslateText(
                                    'Mobile Number:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AutoTranslateText(
                                    customer?.phone ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Menu Card ---
                  Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _ProfileTile(
                          icon: Icons.email,
                          label: 'Support',
                          onTap: launchSupportEmail,
                        ),
                        const Divider(
                            height: 1,
                            thickness: 0.7,
                            indent: 16,
                            endIndent: 16),
                        _ProfileTile(
                          icon: Icons.phone_android,
                          label: 'Brand Helpline',
                          onTap: () =>
                              launchContactDialer(context),
                        ),
                        const Divider(
                            height: 1,
                            thickness: 0.7,
                            indent: 16,
                            endIndent: 16),
                        _ProfileTile(
                          icon: Icons.question_mark,
                          label: 'FAQs',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const FAQsScreen()),
                            );
                          },
                        ),
                        const Divider(
                            height: 1,
                            thickness: 0.7,
                            indent: 16,
                            endIndent: 16),
                        _ProfileTile(
                          icon: Icons.logout,
                          label: 'Logout',
                          isLogout: true,
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLogout;

  const _ProfileTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: AutoTranslateText(
        label,
        style: TextStyle(
          color: isLogout ? Colors.black : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
