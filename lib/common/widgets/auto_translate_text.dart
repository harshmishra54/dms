import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoTranslateText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  const AutoTranslateText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
        this.softWrap,
      }) : super(key: key);

  @override
  State<AutoTranslateText> createState() => _AutoTranslateTextState();
}

class _AutoTranslateTextState extends State<AutoTranslateText> {
  static final _translator = GoogleTranslator();
  static String _langCode = 'en';
  String _translated = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLangAndTranslate();
  }

  Future<void> _loadLangAndTranslate() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString('app_lang') ?? 'en';

    if (_langCode == 'en') {
      setState(() => _translated = widget.text);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final translation = await _translator.translate(widget.text, to: _langCode);
      if (mounted) {
        setState(() {
          _translated = translation.text;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translated = widget.text;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          _isLoading ? widget.text : _translated,
          style: widget.style,
          textAlign: widget.textAlign ?? TextAlign.start,
          maxLines: widget.maxLines, // Keep user-defined maxLines
          overflow: widget.overflow, // Keep user-defined overflow
          softWrap: widget.softWrap ?? true,
        );
      },
    );
  }
}
