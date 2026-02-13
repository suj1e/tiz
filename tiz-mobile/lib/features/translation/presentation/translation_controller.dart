import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/translation_repository.dart';
import '../domain/language.dart';
import '../domain/translation_result.dart';
import '../translation_provider.dart';

/// State for translation operations
sealed class TranslationState {
  const TranslationState();
}

class TranslationIdle extends TranslationState {
  const TranslationIdle();
}

class TranslationDetecting extends TranslationState {
  const TranslationDetecting();
}

class TranslationTranslating extends TranslationState {
  const TranslationTranslating();
}

class TranslationSuccess extends TranslationState {
  final TranslationResult result;
  const TranslationSuccess(this.result);
}

class TranslationError extends TranslationState {
  final String message;
  const TranslationError(this.message);
}

/// Controller for translation operations
class TranslationController extends StateNotifier<TranslationState> {
  final TranslationRepository _repository;

  TranslationController(this._repository) : super(const TranslationIdle());

  Future<void> detectAndTranslate({
    required String text,
    required Language targetLanguage,
  }) async {
    if (text.trim().isEmpty) {
      state = const TranslationError('Please enter text to translate');
      return;
    }

    try {
      // Start with detecting state
      state = const TranslationDetecting();

      // Detect source language
      await _repository.detectLanguage(text);

      // Move to translating state
      state = const TranslationTranslating();

      // Perform translation
      final result = await _repository.translate(
        text: text,
        targetLanguage: targetLanguage,
      );

      state = TranslationSuccess(result);
    } catch (e) {
      state = TranslationError('Translation failed: ${e.toString()}');
    }
  }

  void reset() {
    state = const TranslationIdle();
  }
}

/// Provider for TranslationController
final translationControllerProvider =
    StateNotifierProvider<TranslationController, TranslationState>((ref) {
  final repository = ref.watch(translationRepositoryProvider);
  return TranslationController(repository);
});
