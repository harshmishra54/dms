import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:TrustTags_DMS/main.dart' as app;

Future<void> pumpUntil(WidgetTester tester, bool Function() condition,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    if (condition()) return;
  }
  throw TestFailure("Timeout waiting for condition");
}

Future<void> safeTap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Splash → Landing/Login → OTP Verify automation", (tester) async {
    // ✅ Best-effort clear
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    app.main();
    await tester.pumpAndSettle();

    // ✅ Wait until Landing OR Dashboard/Home appears
    await pumpUntil(
      tester,
          () =>
      find.text("Select Your Identity").evaluate().isNotEmpty ||
          find.text("Login via mobile number").evaluate().isNotEmpty ||
          find.textContaining("Dashboard").evaluate().isNotEmpty ||
          find.byIcon(Icons.logout).evaluate().isNotEmpty ||
          find.byIcon(Icons.person).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 25),
    );

    // ✅ If already logged in, logout first
    if (find.text("Select Your Identity").evaluate().isEmpty &&
        find.text("Login via mobile number").evaluate().isEmpty) {
      await safeTap(tester, find.byIcon(Icons.person));
      await safeTap(tester, find.text("Profile"));
      await safeTap(tester, find.text("Settings"));
      await safeTap(tester, find.text("Logout"));
      await safeTap(tester, find.text("Log out"));
      await safeTap(tester, find.text("Sign out"));
      await safeTap(tester, find.byIcon(Icons.logout));

      // confirm dialog
      await safeTap(tester, find.text("Yes"));
      await safeTap(tester, find.text("OK"));
      await safeTap(tester, find.text("Confirm"));

      // wait for landing
      await pumpUntil(
        tester,
            () => find.text("Select Your Identity").evaluate().isNotEmpty,
        timeout: const Duration(seconds: 20),
      );
    }

    // ---------------- LANDING SCREEN ----------------
    if (find.text("Select Your Identity").evaluate().isNotEmpty) {
      await tester.tap(find.text("Retailer"));
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      await tester.tap(find.text("Next"));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // ---------------- LOGIN SCREEN ----------------
    await pumpUntil(
      tester,
          () => find.text("Login via mobile number").evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );

    final phoneField = find.byKey(const Key("phone_field"));
    final getOtpBtn = find.byKey(const Key("get_otp_btn"));

    expect(phoneField, findsOneWidget);
    expect(getOtpBtn, findsOneWidget);

    // ✅ Use existing Retailer number (can always verify)
    await tester.enterText(phoneField, "8080808084");
    await tester.pumpAndSettle();

    await tester.tap(getOtpBtn);
    await tester.pump(const Duration(milliseconds: 300));

    // loader
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // ---------------- OTP SCREEN ----------------
    await pumpUntil(
      tester,
          () =>
      find.text("Enter OTP").evaluate().isNotEmpty ||
          find.textContaining("OTP has been sent to").evaluate().isNotEmpty ||
          find.text("Verify OTP").evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );

    // ✅ fill OTP
    const otp = "123456";
    for (int i = 0; i < 6; i++) {
      await tester.enterText(find.byKey(Key("otp_$i")), otp[i]);
      await tester.pumpAndSettle(const Duration(milliseconds: 150));
    }

    // ✅ accept terms + verify
    await tester.tap(find.byKey(const Key("terms_checkbox")));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    await tester.tap(find.byKey(const Key("verify_otp_btn")));
    await tester.pumpAndSettle(const Duration(seconds: 15));

    // ✅ final: should go to dashboard (existing retailer user)
    final navigated =
        find.textContaining("Dashboard").evaluate().isNotEmpty ||
            find.textContaining("Home").evaluate().isNotEmpty;

    expect(
      navigated,
      true,
      reason: "OTP verified but did not navigate to expected dashboard/home screen",
    );
  });
}
