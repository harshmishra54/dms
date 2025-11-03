import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';
import '../../../common/widgets/app_status_bar.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          // Custom white AppBar with reduced height
          Material(
            elevation: 0.5, // same as AppBar elevation
            shadowColor: Colors.black.withOpacity(0.2),
            child: Container(
              color: Colors.white,
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'FAQs',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance for alignment
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _FAQCategoryCard(
                          icon: Icons.qr_code_scanner,
                          label: 'Scanning',
                        ),
                        _FAQCategoryCard(
                          icon: Icons.card_giftcard,
                          label: 'Redemption',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        color: Colors.white,
                        height: 120, // Increased height
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.pie_chart_outline, // Close match to image
                              size: 40,
                              color: AppColors.primaryPurple,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Programme',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'FAQs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🟢 FAQ List with answers from the image
                  const _FAQItem(
                    question: 'Why am I getting "0" points after scanning?',
                    answer: 'You may get “0” point if the pack you have scanned is not eligible for points or if it has already been scanned by someone.',
                  ),
                  const _FAQItem(
                    question: 'How can I redeem my points?',
                    answer: 'Go to Redeem section in the app, choose your reward and place your order. Make sure your profile and address are updated.',
                  ),
                  const _FAQItem(
                    question: 'What is DMS Program?',
                    answer: 'It is a loyalty programme by DMS to reward farmers and retailers for their purchase.',
                  ),
                  const _FAQItem(
                    question: 'How can I edit my profile details such as shop name, name, address etc?',
                    answer: 'Click on profile icon on top right, select edit and update your details. Make sure you click on SAVE.',
                  ),
                  const _FAQItem(
                    question: 'Why am I getting "Duplicate Scan" message?',
                    answer: 'You may get “Duplicate Scan” message if the code you scanned has already been used by someone else.',
                  ),
                  const _FAQItem(question: 'How do I contact customer support?',
                      answer: 'You can find contact information for customer support in the Help or Contact Us section within the app settings.'),
                  const _FAQItem(question: 'Are the points trasferable?',
                      answer: 'No, points are linked to your account and are non-transferable.'),
                  const _FAQItem(question: 'How long ae my points valid',
                      answer: 'Points usually have an expiry date. You can check the validity period in the My Points or Rewards History section.'),


                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLarge;

  const _FAQCategoryCard({
    required this.icon,
    required this.label,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isLarge ? 2 : 1,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isLarge ? const Color(0xFFEFF6ED) : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primaryPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                answer,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
