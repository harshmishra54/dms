// lib/common/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define your purple gradient
    const LinearGradient purpleGradient = LinearGradient(
      colors: [
        Color(0xFF8E2DE2),
        Color(0xFF4A00E0),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Apply gradient only when selected
    Widget gradientIcon(IconData icon, bool isSelected) {
      if (isSelected) {
        return ShaderMask(
          shaderCallback: (bounds) =>
              purpleGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Icon(icon, color: Colors.white), // your actual icon
        );
      } else {
        return Icon(icon, color: Colors.grey);
      }
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      showUnselectedLabels: true,
      selectedItemColor: const Color(0xFF8E2DE2), // selected label color
      unselectedItemColor: Colors.grey, // unselected label color
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: gradientIcon(Icons.dashboard, currentIndex == 0),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: gradientIcon(Icons.add_shopping_cart, currentIndex == 1),
          label: 'Place Order',
        ),
        BottomNavigationBarItem(
          icon: gradientIcon(Icons.qr_code_scanner, currentIndex == 2),
          label: 'Scan Reward',
        ),
        BottomNavigationBarItem(
          icon: gradientIcon(Icons.campaign, currentIndex == 3),
          label: 'Schemes',
        ),
      ],
    );
  }
}
