import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AutoTranslateText extends StatefulWidget {
  final String text;

  // All Text widget properties
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const AutoTranslateText(
      this.text, {
        Key? key,
        this.style,
        this.strutStyle,
        this.textAlign,
        this.textDirection,
        this.locale,
        this.softWrap,
        this.overflow,
        this.textScaler,
        this.maxLines,
        this.semanticsLabel,
        this.textWidthBasis,
        this.textHeightBehavior,
        this.selectionColor,
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
    _loadLanguageAndTranslate();
  }

  @override
  void didUpdateWidget(covariant AutoTranslateText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only re-translate if the input text changed
    if (oldWidget.text != widget.text) {
      _loadLanguageAndTranslate();
    }
  }

  Future<void> _loadLanguageAndTranslate() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('app_lang') ?? 'en';

    if (_langCode != lang || _translated.isEmpty) {
      _langCode = lang;
    }

    if (_langCode == 'en') {
      setState(() => _translated = widget.text);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final translated = await _translator.translate(widget.text, to: _langCode);

      if (mounted) {
        setState(() {
          _translated = translated.text;
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
    return Text(
      _isLoading ? widget.text : _translated,

      // Forward ALL Text widget parameters
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }
}
