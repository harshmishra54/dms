import 'package:flutter/material.dart';

class SchemesTabHeader extends StatelessWidget {
  const SchemesTabHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Available Schemes",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
