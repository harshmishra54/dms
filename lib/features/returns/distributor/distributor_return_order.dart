import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/app_status_bar.dart'; // Custom status bar
import '../../../common/app_colors.dart'; // Theme colors

class DistributorReturnOrder extends StatelessWidget {
  const DistributorReturnOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7FF),
      body: Column(
        children: [
          const AppStatusBar(),

          // Custom AppBar with Back button and centered title
          Container(
            color: Colors.white,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Back button on the left
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // Centered title
                const Center(
                  child: AutoTranslateText(
                    'Return Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Order by OrderId',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // No orders message
                  const Expanded(
                    child: Center(
                      child: AutoTranslateText(
                        'No orders found.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add order return logic here
        },
        backgroundColor: const Color(0xFFA259FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }
}
