import 'package:flutter/material.dart';
import '../../../../common/app_colors.dart';
import '../../authentication/presentation/login_screen.dart';
import '../../../../common/widgets/app_status_bar.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int selectedRoleId = -1; // -1 = not selected
  String selectedRole = '';

  final roles = [
    {'title': 'Retailer', 'id': 3, 'image': 'assets/images/trust_tags.png'},
    {'title': 'Sales / Advisor', 'id': 18, 'image': 'assets/images/trust_tags.png'},
    {'title': 'Distributor', 'id': 1, 'image': 'assets/images/trust_tags.png'},
    {'title': 'Farmer', 'id': 0, 'image': 'assets/images/trust_tags.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          const SizedBox(height: 20),
          Center(
            child: Image.asset('assets/images/trust_tags.png', height: 80),
          ),
          const SizedBox(height: 20),
          const Text("Select Your Identity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Selected Identity cannot be changed later", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: roles.map((role) {
                  final String title = role['title'] as String;
                  final int id = role['id'] as int;
                  final String image = role['image'] as String;
                  final bool isSelected = selectedRole == title;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRole = title;
                        // 👇 if Sales/Advisor, treat >=18 as Sales role
                        if (title == "Sales / Advisor" && id >= 18) {
                          selectedRoleId = 18;
                        } else {
                          selectedRoleId = id;
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple.withOpacity(0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primaryPurple, width: 2)
                            : null,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(image, height: 60),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20,20,20,50),
            child: ElevatedButton(
              onPressed: selectedRoleId == -1
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(
                      selectedRole: selectedRole,
                      selectedRoleId: selectedRoleId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ).copyWith(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return AppColors.topBarColor;
                    }
                    return AppColors.topBarColor;
                  },
                ),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text("Next"),
            ),
          ),
        ],
      ),
    );
  }
}
