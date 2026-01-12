import 'dart:async';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../common/app_colors.dart';
import 'otp_verification_screen.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../../../widgets/contact_us_button.dart';
import '../provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  final String selectedRole;
  final int selectedRoleId;
  const LoginScreen({
    super.key,
    required this.selectedRole,
    required this.selectedRoleId,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  bool showRoleBanner = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hide the banner after 1 second
    Timer(const Duration(seconds: 1), () {
      setState(() {
        showRoleBanner = false;
      });
    });
  }

  Future<void> _handleGetOtp() async {
    final fullPhoneNumber = phoneController.text.trim();

    if (fullPhoneNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.sendOtp(
      phone: fullPhoneNumber,
      context: context,
      selectedRole: widget.selectedRole,
      selectedRoleId: widget.selectedRoleId,
    );

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phoneNumber: fullPhoneNumber,
            selectedRole: widget.selectedRole,
            selectedRoleId: widget.selectedRoleId,
            verificationKey: result['verificationKey'],
            sessionId: result['sessionId'],
            registrationId: result['registrationId'],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText('Failed to send OTP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppStatusBar(),
          const SizedBox(height: 10),

          if (showRoleBanner)
            Container(
              width: double.infinity,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: AutoTranslateText(
                '${widget.selectedRole} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),

          const SizedBox(height: 18),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: const Icon(Icons.arrow_back, size: 26),
                        ),
                        const SizedBox(width: 18),
                        const AutoTranslateText(
                          'Login',
                          style: TextStyle(fontSize: 20, letterSpacing: 0.2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AutoTranslateText(
                      'Login via mobile number',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AutoTranslateText(
                      'Select your country code and enter your mobile number to get an OTP',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IntlPhoneField(
                      key: const Key("phone_field"),
                      controller: phoneController,
                      initialCountryCode: 'IN',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        border: OutlineInputBorder(),
                        errorText: null, // remove automatic error
                      ),
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.disabled, // disable auto validation
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key("get_otp_btn"),
                        onPressed: !isLoading ? _handleGetOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : const AutoTranslateText(
                          'Get OTP',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: ContactUsTextLink(),
          ),
        ],
      ),
    );
  }
}
