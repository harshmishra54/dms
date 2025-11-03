import 'dart:convert';
import 'dart:io';

void main() async {
  final translations = <String, String>{};

  // Regex to find Text("...") strings in your Flutter code
  final textRegex = RegExp(r'Text\(\s*"([^"]+)"\s*\)');

  void scanDirectory(Directory dir) {
    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = entity.readAsStringSync();
        for (final match in textRegex.allMatches(content)) {
          final text = match.group(1)!;
          final key = text
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
              .replaceAll(RegExp(r'^_+|_+$'), '');
          translations[key] = text;
        }
      }
    }
  }

  final libDir = Directory('lib');
  scanDirectory(libDir);

  final outDir = Directory('assets/translations');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final enFile = File('${outDir.path}/en.json');
  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(translations));

  print('✅ Extracted ${translations.length} text entries → assets/translations/en.json');
}
