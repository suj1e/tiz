import '../domain/language.dart';
import '../domain/translation_result.dart';

abstract class TranslationRepository {
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  });

  Future<Language> detectLanguage(String text);
}
