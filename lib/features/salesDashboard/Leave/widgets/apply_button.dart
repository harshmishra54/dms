import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../../../../common/app_colors.dart';

class ApplyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ApplyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.topBarColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onPressed,
        child: const AutoTranslateText('Apply Leave', style: TextStyle(fontSize: 16,color: Colors.white)),
      ),
    );
  }
}
