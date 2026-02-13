import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  // Theme
  static const _themeModeKey = 'theme_mode';
  int getThemeMode() => _prefs.getInt(_themeModeKey) ?? 0;
  Future<void> setThemeMode(int mode) => _prefs.setInt(_themeModeKey, mode);

  // Default target language
  static const _targetLangKey = 'target_language';
  String getTargetLanguage() => _prefs.getString(_targetLangKey) ?? 'en';
  Future<void> setTargetLanguage(String lang) => _prefs.setString(_targetLangKey, lang);

  // Webhooks
  static const _webhooksKey = 'webhooks';
  List<String> getWebhooks() => _prefs.getStringList(_webhooksKey) ?? [];
  Future<void> setWebhooks(List<String> urls) => _prefs.setStringList(_webhooksKey, urls);

  // Message read status
  static const _readMessagesKey = 'read_messages';
  Set<String> getReadMessageIds() =>
      (_prefs.getStringList(_readMessagesKey) ?? []).toSet();
  Future<void> setReadMessageIds(Set<String> ids) =>
      _prefs.setStringList(_readMessagesKey, ids.toList());
}

final preferencesProvider = FutureProvider<Preferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return Preferences(prefs);
});
