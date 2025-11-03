import 'package:url_launcher/url_launcher.dart';

Future<void> launchSupportEmail() async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'dhan_saathi@dhanuka.com',
  );

  try {
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No email apps found.';
    }
  } catch (e) {
    print('❌ Error launching email: $e');
  }
}
