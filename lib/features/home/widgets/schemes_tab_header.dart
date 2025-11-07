import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';

class SchemesTabHeader extends StatelessWidget {
  const SchemesTabHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoTranslateText(
      "Available Schemes",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
