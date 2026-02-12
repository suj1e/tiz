import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speech Service
/// Handles speech recognition and text-to-speech for voice call functionality
class SpeechService {
  static SpeechService? _instance;
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isTtsInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _recognizedText = '';
  String _selectedLocaleId = '';
  String _ttsLocale = 'en_US';

  // Callbacks
  VoidCallback? _onListeningStart;
  ValueChanged<String>? _onResult;
  ValueChanged<String>? _onPartialResult;
  VoidCallback? _onListeningEnd;
  ValueChanged<String>? _onError;

  // TTS Callbacks
  VoidCallback? _onSpeakStart;
  VoidCallback? _onSpeakComplete;
  ValueChanged<String>? _onSpeakError;

  SpeechService._();

  /// Get singleton instance
  static SpeechService get instance {
    _instance ??= SpeechService._();
    return _instance!;
  }

  /// Check if speech recognition is available
  bool get isAvailable => _speechToText.isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if currently speaking (TTS)
  bool get isSpeaking => _isSpeaking;

  /// Get recognized text
  String get recognizedText => _recognizedText;

  /// Get initialization status
  bool get isInitialized => _isInitialized;

  /// Get TTS initialization status
  bool get isTtsInitialized => _isTtsInitialized;

  /// Get selected locale
  String get selectedLocaleId => _selectedLocaleId;

  /// Initialize speech recognition and TTS
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Initialize speech recognition
      final isAvailable = await _speechToText.initialize(
        onError: _onErrorListener,
        onStatus: _onStatusListener,
      );

      if (isAvailable) {
        _isInitialized = true;

        // Set default locale (Chinese)
        final locales = await _speechToText.locales();
        final zhLocale = locales.firstWhere(
          (locale) => locale.localeId.startsWith('zh'),
          orElse: () => locales.first,
        );
        _selectedLocaleId = zhLocale.localeId;
      }

      // Initialize TTS
      await _initTts();

      return isAvailable;
    } catch (e) {
      debugPrint('Error initializing speech service: $e');
      return false;
    }
  }

  /// Initialize TTS
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage(_ttsLocale);
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for clarity
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _onSpeakStart?.call();
        debugPrint('TTS started speaking');
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _onSpeakComplete?.call();
        debugPrint('TTS finished speaking');
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        _onSpeakError?.call(msg);
        debugPrint('TTS error: $msg');
      });

      _isTtsInitialized = true;
      debugPrint('TTS initialized with locale: $_ttsLocale');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      _onSpeakError?.call('TTS初始化失败: $e');
    }
  }

  /// Set callbacks for both STT and TTS
  void setCallbacks({
    VoidCallback? onListeningStart,
    ValueChanged<String>? onResult,
    ValueChanged<String>? onPartialResult,
    VoidCallback? onListeningEnd,
    ValueChanged<String>? onError,
    VoidCallback? onSpeakStart,
    VoidCallback? onSpeakComplete,
    ValueChanged<String>? onSpeakError,
  }) {
    _onListeningStart = onListeningStart;
    _onResult = onResult;
    _onPartialResult = onPartialResult;
    _onListeningEnd = onListeningEnd;
    _onError = onError;
    _onSpeakStart = onSpeakStart;
    _onSpeakComplete = onSpeakComplete;
    _onSpeakError = onSpeakError;
  }

  /// Speak text using TTS
  Future<bool> speak(String text, {String? language}) async {
    if (!_isTtsInitialized) {
      await _initTts();
      if (!_isTtsInitialized) {
        _onSpeakError?.call('TTS未初始化');
        return false;
      }
    }

    if (_isSpeaking) {
      debugPrint('Already speaking, stopping current speech');
      await stop();
    }

    try {
      // Set language if provided and different
      if (language != null && language != _ttsLocale) {
        await _flutterTts.setLanguage(language!);
        _ttsLocale = language!;
      }

      await _flutterTts.speak(text);
      return true;
    } catch (e) {
      debugPrint('Error speaking text: $e');
      _onSpeakError?.call('语音合成失败: $e');
      return false;
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }

  /// Set TTS language
  Future<void> setTtsLanguage(String language) async {
    if (_ttsLocale != language) {
      try {
        await _flutterTts.setLanguage(language);
        _ttsLocale = language;
        debugPrint('TTS language changed to: $language');
      } catch (e) {
        debugPrint('Error setting TTS language: $e');
      }
    }
  }

  /// Set speech rate for TTS (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting speech rate: $e');
    }
  }

  /// Set volume for TTS (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Set pitch for TTS (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('Error setting pitch: $e');
    }
  }

  /// Start listening
  Future<bool> startListening({
    String? localeId,
    int pauseFor = 30, // seconds of silence before stopping
    int listenFor = 0, // max duration (0 = unlimited)
    bool partialResults = true,
    String? hintPrompt,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _onError?.call('语音识别未初始化');
        return false;
      }
    }

    if (_isListening) {
      debugPrint('Already listening');
      return false;
    }

    try {
      _recognizedText = '';

      await _speechToText.listen(
        onResult: _onResultListener,
        listenFor: listenFor > 0 ? Duration(seconds: listenFor) : null,
        pauseFor: Duration(seconds: pauseFor),
        partialResults: partialResults,
        localeId: localeId ?? _selectedLocaleId,
        cancelOnError: true,
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: partialResults,
          autoPunctuation: true,
        ),
      );

      _isListening = true;
      _onListeningStart?.call();
      return true;
    } catch (e) {
      debugPrint('Error starting listening: $e');
      _onError?.call('无法启动语音识别: $e');
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
    _onListeningEnd?.call();
  }

  /// Cancel listening (discard results)
  Future<void> cancelListening() async {
    if (!_isListening) return;

    await _speechToText.cancel();
    _isListening = false;
    _recognizedText = '';
    _onListeningEnd?.call();
  }

  /// Get available locales
  Future<List<dynamic>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _speechToText.locales();
  }

  /// Set locale
  Future<void> setLocale(String localeId) async {
    _selectedLocaleId = localeId;
  }

  /// Get locale display name
  String getLocaleDisplayName(String localeId) {
    // Simplified locale display name mapping
    final displayNames = {
      'zh_CN': '简体中文',
      'zh_TW': '繁體中文',
      'en_US': 'English (US)',
      'en_GB': 'English (UK)',
      'ja_JP': '日本語',
      'ko_KR': '한국어',
      'fr_FR': 'Français',
      'de_DE': 'Deutsch',
      'es_ES': 'Español',
      'ru_RU': 'Русский',
    };

    return displayNames[localeId] ?? localeId;
  }

  /// Get common locales for quick selection
  List<LocaleName> getCommonLocales() {
    return [
      const LocaleName('zh_CN', '简体中文'),
      const LocaleName('en_US', 'English (US)'),
      const LocaleName('ja_JP', '日本語'),
      const LocaleName('ko_KR', '한국어'),
    ];
  }

  /// Speech result listener
  void _onResultListener(dynamic result) {
    _recognizedText = result.recognizedWords;

    if (result.finalResult) {
      _onResult?.call(_recognizedText);
      _isListening = false;
      _onListeningEnd?.call();
    } else {
      _onPartialResult?.call(_recognizedText);
    }
  }

  /// Error listener
  void _onErrorListener(dynamic error) {
    debugPrint('Speech recognition error: ${error.errorMsg}');
    _isListening = false;

    String errorMessage;
    switch (error.errorCode) {
      case 'network_error':
        errorMessage = '网络错误，请检查网络连接';
        break;
      case 'no_match':
        errorMessage = '未识别到语音';
        break;
      case 'audio_error':
        errorMessage = '音频错误';
        break;
      case 'client_error':
        errorMessage = '客户端错误';
        break;
      case 'permission_denied':
        errorMessage = '麦克风权限被拒绝';
        break;
      default:
        errorMessage = error.errorMsg;
    }

    _onError?.call(errorMessage);
    _onListeningEnd?.call();
  }

  /// Status listener
  void _onStatusListener(String status) {
    debugPrint('Speech recognition status: $status');

    switch (status) {
      case 'listening':
        _isListening = true;
        break;
      case 'notListening':
        _isListening = false;
        break;
      case 'done':
        _isListening = false;
        break;
    }
  }

  /// Reset state
  void reset() {
    _recognizedText = '';
    _isListening = false;
    _isSpeaking = false;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _speechToText.cancel();
    await _flutterTts.stop();
    _isInitialized = false;
    _isTtsInitialized = false;
    _isListening = false;
    _isSpeaking = false;
    _onListeningStart = null;
    _onResult = null;
    _onPartialResult = null;
    _onListeningEnd = null;
    _onError = null;
    _onSpeakStart = null;
    _onSpeakComplete = null;
    _onSpeakError = null;
  }
}

/// Locale Name Extension
/// Provides display name for locales
class LocaleName {
  final String localeId;
  final String displayName;

  const LocaleName(this.localeId, this.displayName);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocaleName && other.localeId == localeId;
  }

  @override
  int get hashCode => localeId.hashCode;
}
