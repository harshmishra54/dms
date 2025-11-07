import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class NewProductLaunchSection extends StatelessWidget {
  const NewProductLaunchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AutoTranslateText("New Product Launch Details", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/trust_tags.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
