import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import '../app_colors.dart';

class AppStatusBar extends StatelessWidget {
  const AppStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isAndroid ? 40 : 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.topBarGradient, // ✅ Gradient here
      ),
    );
  }
}
