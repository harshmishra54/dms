import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../provider/invite_earn_provider.dart';
import 'package:TrustTags_DMS/common/app_colors.dart';

class InviteEarnScreen extends StatefulWidget {
  const InviteEarnScreen({Key? key}) : super(key: key);

  @override
  State<InviteEarnScreen> createState() => _InviteEarnScreenState();
}

class _InviteEarnScreenState extends State<InviteEarnScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InviteEarnProvider>(context, listen: false)
          .generateReferralCode();
    });
  }

  void _copyReferralCode(BuildContext context, String referralCode) {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareReferralCode(BuildContext context, InviteEarnProvider provider) {
    final code = provider.inviteEarnResponse?.referralCode ?? '';
    if (code.isNotEmpty) {
      final dummyLink = "https://example.com/referral?code=$code";
      final message = "Join TrustTags DMS using my referral code: $code\nClick here to install: $dummyLink";

      Share.share(message);
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<InviteEarnProvider>(
      builder: (context, provider, child) {
        final referralCode = provider.inviteEarnResponse?.referralCode ?? '---';

        return Scaffold(
          body: Column(
            children: [
              const AppStatusBar(),
              Material(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: AutoTranslateText(
                          'Invite & Earn',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Top Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: const Column(
                            children: [
                              AutoTranslateText(
                                "Invite your friends & earn rewards!",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Text(
                                "Share your referral code and get 20 points for each friend who joins.",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Referral Code Card
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Text(
                                  "Your Referral Code",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                provider.isLoading
                                    ? const CircularProgressIndicator()
                                    : Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade50,
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.deepPurple,
                                              width: 2),
                                        ),
                                        child: Text(
                                          referralCode,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                              color: Colors.deepPurple),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy,
                                            color: AppColors.topBarColor),
                                        onPressed: referralCode != '---'
                                            ? () => _copyReferralCode(
                                            context, referralCode)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: provider.isLoading
                                        ? null
                                        : () =>
                                        _shareReferralCode(context, provider),
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Share Now",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                      backgroundColor: AppColors.topBarColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
