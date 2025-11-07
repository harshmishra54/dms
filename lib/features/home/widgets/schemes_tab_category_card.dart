import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class SchemesTabCategoryCard extends StatelessWidget {
  const SchemesTabCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          AutoTranslateText(
            "Scheme Category",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }
}
