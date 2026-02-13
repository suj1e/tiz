import 'package:flutter/foundation.dart';

/// Mock mode configuration
/// Used to control whether the app uses mock data
class MockConfig extends ChangeNotifier {
  static final MockConfig _instance = MockConfig._internal();
  factory MockConfig() => _instance;
  MockConfig._internal();

  bool _isMockMode = false;

  /// Whether mock mode is currently enabled
  bool get isMockMode => _isMockMode;

  /// Toggle mock mode
  void toggle() {
    _isMockMode = !_isMockMode;
    debugPrint('[MockConfig] Mock mode: ${_isMockMode ? "ON" : "OFF"}');
    notifyListeners();
  }

  /// Set mock mode
  void setMockMode(bool enabled) {
    if (_isMockMode != enabled) {
      _isMockMode = enabled;
      debugPrint('[MockConfig] Mock mode: ${_isMockMode ? "ON" : "OFF"}');
      notifyListeners();
    }
  }
}
