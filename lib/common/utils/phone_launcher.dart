import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchContactDialer(BuildContext context) async {
  final Uri uri = Uri(scheme: 'tel', path: '18001021022');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not launch the dialer')),
    );
  }
}
