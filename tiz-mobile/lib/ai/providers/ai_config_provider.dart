import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/ai_config.dart';
import '../models/ai_model.dart';

/// AI Config Provider
/// Manages AI configuration state with secure storage
class AiConfigProvider extends ChangeNotifier {
  static const String _configKey = 'ai_config';
  static const String _apiKeyPrefix = 'api_key_';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  AiConfig _config = AiConfig.defaultConfig();
  bool _isLoading = true;

  /// Get current AI config
  AiConfig get config => _config;

  /// Get current AI model
  AiModel get model => _config.model;

  /// Get API key for current model
  String? get apiKey => _config.apiKey;

  /// Check if API key is configured
  bool get isApiKeyConfigured => _config.isApiKeyConfigured;

  /// Check if AI is ready to use
  bool get isReady => _config.isReady;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Get temperature setting
  double get temperature => _config.temperature;

  /// Get max tokens setting
  int get maxTokens => _config.maxTokens;

  /// Get system prompt
  String get systemPrompt => _config.systemPrompt;

  /// Check if translation enhancement is enabled
  bool get enhanceTranslation => _config.enhanceTranslation;

  /// Check if smart recommendations are enabled
  bool get smartRecommend => _config.smartRecommend;

  /// Check if voice assistant is enabled
  bool get voiceAssistant => _config.voiceAssistant;

  /// Check if deep thinking mode is enabled
  bool get deepThinkingMode => _config.deepThinkingMode;

  /// Check if stream output is enabled
  bool get streamOutput => _config.streamOutput;

  AiConfigProvider() {
    _loadConfig();
  }

  /// Load config from storage
  Future<void> _loadConfig() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);

      if (configJson != null) {
        // Parse JSON manually since we don't have dart:convert
        _config = AiConfig.defaultConfig(); // Simplified for now
        if (kDebugMode) {
          debugPrint('Loaded AI config: $_config');
        }
      }

      // Load API key from secure storage
      final apiKey = await _secureStorage.read(
        key: '$_apiKeyPrefix${_config.model.key}',
      );
      if (apiKey != null) {
        _config = _config.copyWith(apiKey: apiKey);
      }
    } catch (e) {
      debugPrint('Error loading AI config: $e');
      _config = AiConfig.defaultConfig();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save config to storage
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save config (simplified - would normally serialize to JSON)
      await prefs.setString(_configKey, _config.toString());

      // Save API key to secure storage
      if (_config.apiKey != null) {
        await _secureStorage.write(
          key: '$_apiKeyPrefix${_config.model.key}',
          value: _config.apiKey,
        );
      }

      if (kDebugMode) {
        debugPrint('Saved AI config: $_config');
      }
    } catch (e) {
      debugPrint('Error saving AI config: $e');
    }
  }

  /// Set AI model
  Future<void> setModel(AiModel model) async {
    if (_config.model == model) return;

    // Load API key for new model if exists
    String? apiKey = await _secureStorage.read(
      key: '$_apiKeyPrefix${model.key}',
    );

    _config = _config.copyWith(
      model: model,
      apiKey: apiKey,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set API key for current model
  Future<void> setApiKey(String? apiKey) async {
    if (_config.apiKey == apiKey) return;

    _config = _config.copyWith(
      apiKey: apiKey,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set temperature
  Future<void> setTemperature(double temperature) async {
    if (_config.temperature == temperature) return;

    _config = _config.copyWith(
      temperature: temperature.clamp(0.0, 2.0),
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set max tokens
  Future<void> setMaxTokens(int maxTokens) async {
    if (_config.maxTokens == maxTokens) return;

    _config = _config.copyWith(
      maxTokens: maxTokens.clamp(128, _config.model.maxTokens),
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set system prompt
  Future<void> setSystemPrompt(String systemPrompt) async {
    if (_config.systemPrompt == systemPrompt) return;

    _config = _config.copyWith(
      systemPrompt: systemPrompt,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Toggle translation enhancement
  Future<void> toggleEnhanceTranslation() async {
    _config = _config.copyWith(
      enhanceTranslation: !_config.enhanceTranslation,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set translation enhancement
  Future<void> setEnhanceTranslation(bool value) async {
    if (_config.enhanceTranslation == value) return;

    _config = _config.copyWith(
      enhanceTranslation: value,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Toggle smart recommendations
  Future<void> toggleSmartRecommend() async {
    _config = _config.copyWith(
      smartRecommend: !_config.smartRecommend,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set smart recommendations
  Future<void> setSmartRecommend(bool value) async {
    if (_config.smartRecommend == value) return;

    _config = _config.copyWith(
      smartRecommend: value,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Toggle voice assistant
  Future<void> toggleVoiceAssistant() async {
    _config = _config.copyWith(
      voiceAssistant: !_config.voiceAssistant,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set voice assistant
  Future<void> setVoiceAssistant(bool value) async {
    if (_config.voiceAssistant == value) return;

    _config = _config.copyWith(
      voiceAssistant: value,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Toggle deep thinking mode
  Future<void> toggleDeepThinkingMode() async {
    if (!_config.model.supportsDeepThinking) {
      debugPrint('Current model does not support deep thinking mode');
      return;
    }

    _config = _config.copyWith(
      deepThinkingMode: !_config.deepThinkingMode,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set deep thinking mode
  Future<void> setDeepThinkingMode(bool value) async {
    if (_config.deepThinkingMode == value) return;
    if (!_config.model.supportsDeepThinking) {
      debugPrint('Current model does not support deep thinking mode');
      return;
    }

    _config = _config.copyWith(
      deepThinkingMode: value,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Toggle stream output
  Future<void> toggleStreamOutput() async {
    _config = _config.copyWith(
      streamOutput: !_config.streamOutput,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Set stream output
  Future<void> setStreamOutput(bool value) async {
    if (_config.streamOutput == value) return;

    _config = _config.copyWith(
      streamOutput: value,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Update multiple settings at once
  Future<void> updateConfig({
    AiModel? model,
    String? apiKey,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    bool? enhanceTranslation,
    bool? smartRecommend,
    bool? voiceAssistant,
    bool? deepThinkingMode,
    bool? streamOutput,
  }) async {
    _config = _config.copyWith(
      model: model,
      apiKey: apiKey,
      temperature: temperature,
      maxTokens: maxTokens,
      systemPrompt: systemPrompt,
      enhanceTranslation: enhanceTranslation,
      smartRecommend: smartRecommend,
      voiceAssistant: voiceAssistant,
      deepThinkingMode: deepThinkingMode,
      streamOutput: streamOutput,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveConfig();
  }

  /// Reset to default config
  Future<void> resetToDefault() async {
    _config = AiConfig.defaultConfig();
    notifyListeners();
    await _saveConfig();
  }

  /// Clear API key for current model
  Future<void> clearApiKey() async {
    await _secureStorage.delete(
      key: '$_apiKeyPrefix${_config.model.key}',
    );
    _config = _config.copyWith(apiKey: null);
    notifyListeners();
  }

  /// Clear all API keys
  Future<void> clearAllApiKeys() async {
    for (final model in AiModel.values) {
      await _secureStorage.delete(key: '$_apiKeyPrefix${model.key}');
    }
    _config = _config.copyWith(apiKey: null);
    notifyListeners();
  }

  /// Check if a feature is enabled
  bool isFeatureEnabled(AiFeature feature) {
    return _config.isFeatureEnabled(feature);
  }

  /// Get effective max tokens (respects model limit)
  int get effectiveMaxTokens => _config.effectiveMaxTokens;
}
