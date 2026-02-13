import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/api_translation_repository.dart';
import 'data/mock_translation_repository.dart';
import 'data/translation_repository.dart';

/// Flag to control mock vs real API usage
/// Set to true for development, false for production
const bool USE_MOCK = true;

/// Provider for TranslationRepository
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  if (USE_MOCK) {
    return MockTranslationRepository();
  }
  return ApiTranslationRepository();
});
