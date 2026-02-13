import '../domain/language.dart';
import '../domain/translation_result.dart';
import 'translation_repository.dart';

/// API implementation of TranslationRepository for production
class ApiTranslationRepository implements TranslationRepository {
  // TODO: Add Dio client and API configuration
  // final Dio _dio;

  ApiTranslationRepository();

  @override
  Future<Language> detectLanguage(String text) async {
    // TODO: Implement API call to /api/v1/translation/detect
    // POST /api/v1/translation/detect
    // Body: { "text": "..." }
    // Response: { "language": "zh", "confidence": 0.95 }
    throw UnimplementedError('API translation not yet implemented');
  }

  @override
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  }) async {
    // TODO: Implement API call to /api/v1/translation/translate
    // POST /api/v1/translation/translate
    // Body: { "text": "...", "targetLanguage": "en" }
    // Response: {
    //   "originalText": "...",
    //   "detectedSourceLanguage": "zh",
    //   "targetLanguage": "en",
    //   "translatedText": "..."
    // }
    throw UnimplementedError('API translation not yet implemented');
  }
}
