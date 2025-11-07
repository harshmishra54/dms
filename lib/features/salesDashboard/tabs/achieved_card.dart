import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class Product {
  final String name;
  final int target;

  Product({required this.name, required this.target});
}

class AchievedTargetListingScreen extends StatelessWidget {
  // Dummy data
  final List<Product> products = [
    Product(name: "ABADDON", target: 100),
    Product(name: "Parijat beej", target: 200),
    Product(name: "SEEDCO", target: 150),
    Product(name: "AADAT", target: 300),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const AppStatusBar(),
          // 🔹 Custom Header (flat, center aligned)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            width: double.infinity,
            color: Colors.white,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const AutoTranslateText(
                  "Achieved Target",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Product list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left side → Product name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoTranslateText(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.track_changes,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                AutoTranslateText(
                                  "Tracking target...",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Right side → Target badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: AutoTranslateText(
                            "Achieved: ${product.target}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
