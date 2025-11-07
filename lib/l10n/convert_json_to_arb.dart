import 'dart:convert';
import 'dart:io';

void main() async {
  final inputDir = Directory('assets/translations');
  final outputDir = Directory('lib/l10n');

  if (!inputDir.existsSync()) {
    print('❌ Folder not found: assets/translations');
    return;
  }

  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
    print('✅ Created folder: lib/l10n');
  }

  final files = inputDir.listSync().where((f) => f.path.endsWith('.json'));

  for (final file in files) {
    final name = file.uri.pathSegments.last.split('.').first;
    final content = await File(file.path).readAsString();

    try {
      final jsonMap = json.decode(content);
      final arbMap = {
        '@@locale': name,
        ...jsonMap,
      };

      final arbContent = const JsonEncoder.withIndent('  ').convert(arbMap);
      final arbFile = File('${outputDir.path}/app_$name.arb');
      await arbFile.writeAsString(arbContent);
      print('✅ Converted ${file.path} → ${arbFile.path}');
    } catch (e) {
      print('❌ Failed to convert ${file.path}: $e');
    }
  }

  print('\n🎉 All JSON files converted to ARB successfully!');
}
