import 'language.dart';

class TranslationResult {
  final String originalText;
  final Language detectedSourceLanguage;
  final Language targetLanguage;
  final String translatedText;

  const TranslationResult({
    required this.originalText,
    required this.detectedSourceLanguage,
    required this.targetLanguage,
    required this.translatedText,
  });
}
