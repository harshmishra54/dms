import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/app_colors.dart';
import '../../authentication/presentation/login_screen.dart';
import '../../../../common/widgets/app_status_bar.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int selectedRoleId = -1;
  String selectedRole = '';
  String selectedLangCode = 'en'; // default

  final roles = [
    {'title': 'Retailer', 'id': 3, 'image': 'assets/images/crystal_logo.jpeg'},
    {'title': 'Sales / Advisor', 'id': 18, 'image': 'assets/images/crystal_logo.jpeg'},
    {'title': 'Distributor', 'id': 1, 'image': 'assets/images/crystal_logo.jpeg'},
    {'title': 'Farmer', 'id': 0, 'image': 'assets/images/crystal_logo.jpeg'},
  ];

  final languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'हिन्दी', 'code': 'hi'},
    {'name': 'বাংলা', 'code': 'bn'},
    {'name': 'తెలుగు', 'code': 'te'},
    {'name': 'मराठी', 'code': 'mr'},
    {'name': 'தமிழ்', 'code': 'ta'},
    {'name': 'ଓଡ଼ିଆ', 'code': 'or'},
    {'name': 'ગુજરાતી', 'code': 'gu'},
    {'name': 'ಕನ್ನಡ', 'code': 'kn'},
    {'name': 'ਪੰਜਾਬੀ', 'code': 'pa'},
    {'name': 'संस्कृत', 'code': 'sa'},
    {'name': 'मैथिली', 'code': 'mai'},
    {'name': 'कोंकणी', 'code': 'kok'},
    {'name': 'नेपाली', 'code': 'ne'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLangCode = prefs.getString('app_lang') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_lang', code);
    setState(() {
      selectedLangCode = code;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language changed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppStatusBar(),
          const SizedBox(height: 20),
          // App logo
          Center(
            child: Image.asset(
              'assets/images/crystal_logo.jpeg',
              height: 80,
            ),
          ),
          const SizedBox(height: 20),

          // Language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AutoTranslateText(
                    "Select Language:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLangCode,
                      borderRadius: BorderRadius.circular(10),
                      items: languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang['code']!,
                          child: Text(lang['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _changeLanguage(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Titles
          const AutoTranslateText(
            "Select Your Identity",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const AutoTranslateText(
            "Selected Identity cannot be changed later",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Role selection grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1,
              ),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                final String title = role['title'] as String;
                final int id = role['id'] as int;
                final String image = role['image'] as String;
                final bool isSelected = selectedRole == title;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRole = title;
                      selectedRoleId = (title == "Sales / Advisor" && id >= 18)
                          ? 18
                          : id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryPurple.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(image, height: 60),
                        const SizedBox(height: 10),
                        AutoTranslateText(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isSelected
                                ? AppColors.primaryPurple
                                : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Next button
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: SizedBox(
              width: double.infinity,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const AutoTranslateText("Next"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
