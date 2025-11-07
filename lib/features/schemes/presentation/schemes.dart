import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/schemes/presentation/scheme_program_screen.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../../../common/app_colors.dart';

class SchemesScreen extends StatelessWidget {
  const SchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FB),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ✅ Status Bar
            const AppStatusBar(),

            // ✅ Custom AppBar (White Background)
            Container(
              color: Colors.white,
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const AutoTranslateText(
                    'Schemes',
                    style: TextStyle(
                      color: Colors.black, // ✅ Black text
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),

            // ✅ Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: AutoTranslateText('Opening scheme details...'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      // Navigate to Scheme Program Screen after delay
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SchemeProgramScreen()),
                        );
                      });
                    },

                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Image.asset(
                              'assets/images/trust_tags.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 160,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                AutoTranslateText(
                                  'Test SIXR scheme',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.topBarColor,
                                  ),
                                ),
                                SizedBox(height: 6),
                                AutoTranslateText(
                                  'Scan to participate in the scheme',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                AutoTranslateText(
                                  'Valid from 17-Jun-25 To 18-Jun-25',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
