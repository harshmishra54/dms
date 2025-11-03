import 'package:flutter/material.dart';
//light theme
class AppColors {
  static const Color primaryPurple = Color(0xFFA259FF); // Final match
  static const Color topBarColor = Color(0xFFA259FF);   // Used for status/app bar
  static const Color primaryColor = Color(0xFFB66AC2);
  static const Color bgColor = Color(0xFFFDF7FC);
  static const scaffoldColor = Color(0xFFFDF7FC);
  static const greyColor = Colors.grey;
  static const LinearGradient topBarGradient = LinearGradient(
    colors: [Color(0xFFA259FF), Color(0xFF673AB7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // static const Color topBarColor = Color(0xFFA259FF);
}
