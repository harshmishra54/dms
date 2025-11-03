import 'package:flutter/material.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import '../common/utils/phone_launcher.dart'; // 👈 Import here

class ContactUsTextLink extends StatelessWidget {
  const ContactUsTextLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: RichText(
          text: TextSpan(
            text: 'Need Help? ',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () => launchContactDialer(context), // ✅ Reused
                  child: Text(
                    'Contact us',
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
