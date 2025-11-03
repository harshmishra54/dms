import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/home/presentation/scan_screen.dart';
import 'package:flutter/material.dart';
import 'inward_screen.dart';


class DistributorScanScreen extends StatelessWidget {
  const DistributorScanScreen
      ({Key? key}) : super(key: key);

  void _navigateToReward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanQRScreen()),
    );
  }

  void _navigateToInward(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InwardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Column(
        children: [
          // Top Section
          const AppStatusBar(),
          Container(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanner',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/trust_tags.png'), // Change to your logo path
                )
              ],
            ),
          ),

          const SizedBox(height: 60),

          // Scanner Reward Button
          GestureDetector(
            onTap: () => _navigateToReward(context),
            child: _circularButton(
              icon: Icons.card_giftcard,
              label: 'Scanner Reward',
              iconImage: 'assets/images/trust_tags.png', // Replace with actual asset if using image
            ),
          ),

          const SizedBox(height: 40),

          // Inward Scan Button
          GestureDetector(
            onTap: () => _navigateToInward(context),
            child: _circularButton(
              icon: Icons.local_shipping,
              label: 'Inward Scan',
              iconImage: 'assets/images/trust_tags.png', // Replace with actual asset if using image
            ),
          ),
        ],
      ),

      // Bottom Navigation

    );
  }

  Widget _circularButton({
    required String label,
    IconData? icon,
    String? iconImage,
  }) {
    return Container(
      width: 180,
      height: 180,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFDB8CFF), Color(0xFF9D4EDD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconImage != null)
              Image.asset(iconImage, height: 60)
            else if (icon != null)
              Icon(icon, color: Colors.white, size: 60),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
