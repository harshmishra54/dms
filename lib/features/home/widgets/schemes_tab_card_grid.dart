import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class SchemesTabCardGrid extends StatelessWidget {
  const SchemesTabCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyList = List.generate(6, (index) => index);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: dummyList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 220,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  'assets/images/VNR_logo.jpeg',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoTranslateText("Scheme Title", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    AutoTranslateText(
                      "Short description about the scheme...",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
