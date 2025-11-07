import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/app_status_bar.dart';
import '../../../../common/app_colors.dart';

class SchemeProgramScreen extends StatelessWidget {
  const SchemeProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ✅ Custom Status Bar
            const AppStatusBar(),

            // ✅ Custom AppBar with green top bar
            Material(
              elevation: 3,
              shadowColor: Colors.black26,
              child: Container(
                height: kToolbarHeight,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    const AutoTranslateText(
                      'Scheme Programme',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),


            // ✅ Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Terms and Condition Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.article_outlined, size: 36),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AutoTranslateText(
                              'Terms and Condition',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            AutoTranslateText('TEXT1'),
                            AutoTranslateText('TEXT2'),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ✅ Program Information Header
                    const AutoTranslateText(
                      'Program Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ PDF Card Section
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Image.asset(
                          'assets/images/trust_tags.png', // You can use your PDF image here
                          width: 40,
                        ),
                        title: const AutoTranslateText(
                          'About the Program',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () {
                          // TODO: Open PDF
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
