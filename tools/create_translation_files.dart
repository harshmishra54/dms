import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// 🌍 Supported language codes for Indian languages
final languages = {
  'hi': 'Hindi',
  'bn': 'Bengali',
  'gu': 'Gujarati',
  'ta': 'Tamil',
  'te': 'Telugu',
  'ml': 'Malayalam',
  'kn': 'Kannada',
  'mr': 'Marathi',
  'pa': 'Punjabi',
  'or': 'Odia',
  'as': 'Assamese',
};

Future<void> main() async {
  final inputFile = File('assets/translations/en.json');
  if (!inputFile.existsSync()) {
    print('❌ Missing: assets/translations/en.json');
    return;
  }

  final enMap = json.decode(await inputFile.readAsString()) as Map<String, dynamic>;

  // Create output directory if not exists
  final outDir = Directory('assets/translations');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  print('🌐 Translating ${enMap.length} keys... this may take a few minutes.');

  for (final entry in languages.entries) {
    final langCode = entry.key;
    final langName = entry.value;
    final translated = <String, String>{};

    for (final key in enMap.keys) {
      final text = enMap[key]!;
      final safeText = text
          .toString()
          .replaceAll(RegExp(r'\$\{[^}]+\}'), '_VAR_')
          .replaceAll(RegExp(r'\$[a-zA-Z0-9_]+'), '_VAR_');

      final translatedText = await translateText(safeText, langCode);
      final restoredText = restoreVariables(translatedText, text.toString());
      translated[key] = restoredText;
    }

    final outFile = File('${outDir.path}/$langCode.json');
    outFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(translated));
    print('✅ Created $langCode.json → $langName');
  }

  print('\n🎉 All translations generated inside assets/translations/');
}

// 🧠 Translate text using Google Translate API (no key required)
Future<String> translateText(String text, String targetLang) async {
  final uri = Uri.parse(
      'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}');
  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data[0] as List).map((e) => e[0]).join('');
  }
  return text;
}

// 🔁 Restore variable placeholders ($... and ${...})
String restoreVariables(String translated, String original) {
  final vars = RegExp(r'(\$\{[^}]+\}|\$[a-zA-Z0-9_]+)').allMatches(original).map((m) => m.group(0)!).toList();
  var i = 0;
  return translated.replaceAllMapped(RegExp(r'_VAR_'), (_) {
    if (i < vars.length) return vars[i++];
    return '_VAR_';
  });
}
