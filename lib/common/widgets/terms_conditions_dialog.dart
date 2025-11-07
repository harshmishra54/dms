import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import '../app_colors.dart';

void showTermsAndConditionsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent tap outside to dismiss
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(
            maxHeight: 500, // Adjust height as needed
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AutoTranslateText(
                'Terms and Conditions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ✅ Scrollable content with limited height
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoTranslateText(
                        '1. This App entitles the user of the app with the possibility of winning reward points and possibility of claiming a reward points in his/her bank account through UPI transfer or in defined e-wallet account, through registering in scheme(s). The user may or may not win a reward point. He/she will be responsible for selecting their respective bank account or UPI ID or e-wallet for the transfer of the reward points.',
                      ),
                      SizedBox(height: 10),
                      AutoTranslateText(
                        '2. The rewards points scheme(s) as declared by DHANUKA AGRITECH LIMITED from time to time are applicable only on the scan of specifically defined DHANUKA AGRITECH LIMITED packs in the defined states & districts from defined start date to defined end dates on selected batches at the discretion of the company.',
                      ),
                      SizedBox(height: 10),
                      AutoTranslateText(
                        '3. App use is authorized for and limited only to retailers or resellers associated with DHANUKA AGRITECH LIMITED.',
                      ),
                      SizedBox(height: 10),
                      AutoTranslateText(
                        '4. All reward transactions are subject to verification by the company and may be rejected or reversed if fraud is suspected.',
                      ),
                      SizedBox(height: 10),
                      AutoTranslateText(
                        '5. The company reserves the right to modify or terminate any scheme or reward criteria at any time without prior notice.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const AutoTranslateText(
                    'OK',
                    style: TextStyle(
                      color: AppColors.topBarColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
