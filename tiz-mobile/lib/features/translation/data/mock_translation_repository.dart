import 'dart:math';
import '../domain/language.dart';
import '../domain/translation_result.dart';
import 'translation_repository.dart';

class MockTranslationRepository implements TranslationRepository {
  final Random _random = Random();

  @override
  Future<TranslationResult> translate({
    required String text,
    required Language targetLanguage,
  }) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    final sourceLanguage = await detectLanguage(text);

    final translatedText = _generateMockTranslation(text, targetLanguage);

    return TranslationResult(
      originalText: text,
      detectedSourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      translatedText: translatedText,
    );
  }

  @override
  Future<Language> detectLanguage(String text) async {
    await Future.delayed(const Duration(milliseconds: 200));

    if (text.contains(RegExp(r'嘅|喺|唔|佢|咁'))) {
      return Language.yue;
    }
    if (text.contains(RegExp(r'撒|嘛|哈|喔|噻'))) {
      return Language.szc;
    }
    if (text.contains(RegExp(r'[\u4e00-\u9fff]'))) {
      return Language.zh;
    }
    return Language.en;
  }

  String _generateMockTranslation(String text, Language targetLanguage) {
    const mockTranslations = <Language, String>{
      Language.en: '[Mock EN]',
      Language.yue: '[Mock 粤语]',
      Language.szc: '[Mock 川语]',
      Language.zh: '[Mock 中文]',
    };
    final prefix = mockTranslations[targetLanguage] ?? '';
    return '$prefix $text';
  }
}
