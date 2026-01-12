import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/common/widgets/terms_conditions_dialog.dart';
import 'package:TrustTags_DMS/core/utils/token_decryptor.dart';
import 'package:TrustTags_DMS/features/Crystaldoctor/presentation/crystal_doctor_dashboard.dart';
import 'package:TrustTags_DMS/features/dashboard/distributor_home_navigation.dart';
import 'package:TrustTags_DMS/features/farmer/dashboard/farmer_dashboard_homenavigation.dart';
import 'package:TrustTags_DMS/features/farmer/registration/farmer_registration.dart';
import 'package:TrustTags_DMS/features/home/presentation/home_navigation.dart';
import 'package:TrustTags_DMS/features/permissions/permissions_provider.dart';
import 'package:TrustTags_DMS/features/registration/screens/sales_registration_screen.dart';
import 'package:TrustTags_DMS/features/salesDashboard/sales_dashboard_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../provider/otp_provider.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../registration/screens/registration_screen.dart';
import '../../registration/screens/distributor_registration_screen.dart';
import '../../../../widgets/contact_us_button.dart';
import '../../../../data/models/verify_otp_request.dart';
import 'package:provider/provider.dart' as legacy;
import '../provider/auth_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String selectedRole;
  final int selectedRoleId;
  final String verificationKey;
  final String sessionId;
  final String registrationId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.selectedRole,
    required this.selectedRoleId,
    required this.verificationKey,
    required this.sessionId,
    required this.registrationId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isChecked = false;
  String enteredOtp = '';
  late String verificationKey;
  late String sessionId;
  late String registrationId;

  bool isVerifying = false; // 👈 loader for Verify OTP
  bool isResending = false; // 👈 loader for Resend OTP

  // Controllers & focus nodes for sequential OTP input
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    verificationKey = widget.verificationKey;
    sessionId = widget.sessionId;
    registrationId = widget.registrationId;
    _getFcmToken();

    // Focus first field initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNodes.isNotEmpty) FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }
  Future<void> _getFcmToken() async {
    try {
      // ✅ integration_test / widget test me APNS token nahi hota (iOS)
      if (const bool.fromEnvironment('FLUTTER_TEST')) {
        _fcmToken = "TEST_FCM_TOKEN";
        return;
      }

      // ✅ iOS: wait for APNS token
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        debugPrint("APNS token not set yet, skipping FCM token for now");
        _fcmToken = null;
        return;
      }

      _fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint("FCM Token: $_fcmToken");
    } catch (e) {
      debugPrint("FCM Token error: $e");
      _fcmToken = null;
    }
  }


  @override
  void dispose() {
    for (final f in focusNodes) {
      f.dispose();
    }
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Sequential OTP input widget
  Widget buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (controllers[index].text.isEmpty) {
                  // Move focus to previous non-empty field
                  for (int i = index - 1; i >= 0; i--) {
                    if (controllers[i].text.isNotEmpty) {
                      FocusScope.of(context).requestFocus(focusNodes[i]);
                      controllers[i].text = '';
                      break;
                    }
                  }
                }
              }
            },
            child: TextFormField(
              key: Key("otp_$index"),
              controller: controllers[index],
              focusNode: focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isEmpty) return;

                // Keep only first character
                controllers[index].text = value[0];

                // Move focus to next empty field
                for (int i = index + 1; i < 6; i++) {
                  if (controllers[i].text.isEmpty) {
                    FocusScope.of(context).requestFocus(focusNodes[i]);
                    return;
                  }
                }
                // If all fields full, unfocus
                FocusScope.of(context).unfocus();
              },
              onTap: () {
                // Jump to first empty field if user taps any field
                for (int i = 0; i < 6; i++) {
                  if (controllers[i].text.isEmpty) {
                    FocusScope.of(context).requestFocus(focusNodes[i]);
                    break;
                  }
                }
              },
            ),
          ),
        );
      }),
    );
  }

  Future<void> _handleVerifyOtp() async {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please accept the Terms & Conditions")),
      );
      return;
    }

    enteredOtp = controllers.map((c) => c.text).join();

    if (enteredOtp.isEmpty || enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please enter a valid OTP")),
      );
      return;
    }

    setState(() {
      isVerifying = true;
    });

    final otpProvider = legacy.Provider.of<OtpProvider>(context, listen: false);

    final request = VerifyOtpRequest(
      phone: widget.phoneNumber,
      otp: enteredOtp,
      verificationKey: verificationKey,
      sessionId: sessionId,
      registrationId: registrationId,
      userType: widget.selectedRoleId,
      countryCode: "+91",
      fcmToken: _fcmToken,
    );

    final response = await otpProvider.verifyOtp(request);

    setState(() {
      isVerifying = false;
    });
    String roleId = '';


    if (response != null && response.success == 1) {
      final encryptedToken = response.data ?? '';

      if (encryptedToken.isNotEmpty) {
        try {
          final decryptedString = TokenDecryptor.decrypt(encryptedToken);
          final Map<String, dynamic> tokenData = jsonDecode(decryptedString);

          final jwtToken = tokenData['jwt_token'] ?? '';
          final userId = tokenData['id'] ?? '';
          roleId = tokenData['role_id']?.toString() ?? '';

          print("JWT Token: $jwtToken");
          print("UserId: $userId");
          print("role_id: $roleId");

          await SharedPrefsHelper.saveOtpUserData(
            tokenData,
            selectedRoleId: widget.selectedRoleId,
          );
          final container = ProviderScope.containerOf(context, listen: false);
          await container.read(permissionsProvider.notifier).loadPermissions();

        } catch (e) {
          debugPrint("Error decrypting/parsing token: $e");
        }
      }

      // ✅ Navigate based on userFlag
      if (response.userflag == true) {
        // ---- EXISTING USER → go to dashboards based on role
        if (widget.selectedRoleId == 18 && roleId.toString() == '23') {
          // Special case: CrystalDoctorDashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CrystalDoctorDashboard()),
          );
        }
        else if (widget.selectedRoleId == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DistributorHomeNavigation()),
          );
        } else if (widget.selectedRoleId == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeNavigation()),
          );
        } else if (widget.selectedRoleId == 18) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  SalesDashboardScreen()),
          );
        }
        else if (widget.selectedRoleId == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerDashboardHomenavigation()),
          );
        } else {
          // fallback if role not matched
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        // ---- NEW USER → Go to registration (same as before)
        if (widget.selectedRoleId == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        } else if (widget.selectedRoleId == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DistributorRegistrationScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        } else if (widget.selectedRoleId == 18) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SalesRegistrationScreen(phoneNumber: widget.phoneNumber),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FarmerRegistration(phoneNumber: widget.phoneNumber),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(otpProvider.errorMessage ?? "OTP Verification failed")),
      );
    }
  }


  Future<void> _handleResendOtp() async {
    setState(() {
      isResending = true;
    });

    final authProvider =legacy.Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.sendOtp(
      phone: widget.phoneNumber,
      context: context,
      selectedRole: widget.selectedRole,
      selectedRoleId: widget.selectedRoleId,
    );

    setState(() {
      isResending = false;
    });

    if (result != null) {
      setState(() {
        verificationKey = result['verificationKey'];
        sessionId = result['sessionId'];
        registrationId = result['registrationId'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("OTP resent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Failed to resend OTP")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 26),
                ),
                const SizedBox(width: 18),
                const AutoTranslateText(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8F8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AutoTranslateText(
                      'Verify OTP',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AutoTranslateText(
                      'OTP has been sent to - ${widget.phoneNumber}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const AutoTranslateText(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    buildOtpFields(),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Checkbox(
                          key: const Key("terms_checkbox"),
                          value: isChecked,
                          activeColor: AppColors.primaryPurple,
                          onChanged: (val) {
                            setState(() {
                              isChecked = val!;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: AutoTranslateText(
                                    'I Agree to the ',
                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    onTap: () {
                                      showTermsAndConditionsDialog(context);
                                    },
                                    child: AutoTranslateText(
                                      'Terms & Conditions.',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryPurple,
                                        decoration: TextDecoration.underline,
                                        fontSize: 14,
                                      ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        key: const Key("verify_otp_btn"),
                        onPressed: isVerifying ? null : _handleVerifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.topBarColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                        child: isVerifying
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const AutoTranslateText("Verify OTP"),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: Column(
                        children: [
                          const AutoTranslateText("Haven’t Received An OTP?"),
                          TextButton(
                            onPressed: isResending ? null : _handleResendOtp,
                            child: isResending
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            )
                                : AutoTranslateText(
                              "Resend",
                              style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 150),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          ContactUsTextLink(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
