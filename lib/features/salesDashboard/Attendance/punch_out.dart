import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/features/salesDashboard/Attendance/provider/punch_out_provider.dart';

class PunchOut extends StatefulWidget {
  const PunchOut({super.key});

  @override
  State<PunchOut> createState() => _PunchOutState();
}

class _PunchOutState extends State<PunchOut> {
  final TextEditingController _conclusionController = TextEditingController();

  @override
  void dispose() {
    _conclusionController.dispose();
    super.dispose();
  }

  Future<void> _onPunchOut() async {
    final conclusion = _conclusionController.text.trim();

    if (conclusion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("Please enter Summary of the day")),
      );
      return;
    }

    final userId = await SharedPrefsHelper.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: AutoTranslateText("User not found. Please login again.")),
      );
      return;
    }

    final provider = context.read<PunchOutProvider>();
    await provider.submitPunchOut(userId: userId, conclusion: conclusion);

    final response = provider.punchOutResponse;

    // Show the message from the server regardless of success
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(response.message)),
      );

      // Navigate back to SalesDashboard after showing the message
      Future.delayed(const Duration(milliseconds: 100), () {
        _conclusionController.clear();
        Navigator.pop(context, true); // go back to SalesDashboard
      });
    } else if (provider.errorMessage != null) {
      // Show error if request failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: AutoTranslateText(provider.errorMessage!)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppStatusBar(),
          Material(
            elevation: 2,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: kToolbarHeight,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const AutoTranslateText(
                    "Punch Out",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<PunchOutProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AutoTranslateText(
                        "Summary of the day",
                        style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _conclusionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Write your Summary here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _onPunchOut,
                        style: ElevatedButton.styleFrom(
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.topBarColor,
                        ),
                        child: const AutoTranslateText(
                          "Punch Out",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
