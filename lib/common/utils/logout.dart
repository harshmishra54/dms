import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const AutoTranslateText("Logout"),
        content: const AutoTranslateText("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const AutoTranslateText("No"),
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
            },
          ),
          TextButton(
            child: const AutoTranslateText("Yes"),
            onPressed: () async {
              // Clear SharedPreferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navigate to login screen and remove all previous routes
              Navigator.of(context).pushNamedAndRemoveUntil(
                "/login", // make sure you have this route defined
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}
