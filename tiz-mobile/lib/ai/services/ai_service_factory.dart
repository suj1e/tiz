import 'ai_service.dart';
import 'openai_service.dart';
import 'claude_service.dart';
import '../models/ai_model.dart';
import '../models/chat_message.dart';

/// AI Service Factory
/// Creates and manages AI service instances
class AiServiceFactory {
  static AiServiceFactory? _instance;
  final Map<AiModel, AiService> _services = {};

  AiServiceFactory._();

  /// Get singleton instance
  static AiServiceFactory get instance {
    _instance ??= AiServiceFactory._();
    return _instance!;
  }

  /// Get service for model
  AiService getService(AiModel model, {String? apiKey}) {
    if (_services.containsKey(model)) {
      return _services[model]!;
    }

    final service = _createService(model, apiKey);
    _services[model] = service;
    return service;
  }

  /// Create service for model
  AiService _createService(AiModel model, String? apiKey) {
    switch (model) {
      case AiModel.gpt4:
      case AiModel.gpt35:
        return OpenAiService(apiKey: apiKey);

      case AiModel.claude:
        return ClaudeService(apiKey: apiKey);

      case AiModel.gemini:
      case AiModel.local:
      case AiModel.custom:
        // For now, fall back to OpenAI for unsupported models
        // In production, implement GeminiService, LocalModelService, etc.
        return OpenAiService(apiKey: apiKey);
    }
  }

  /// Get service by model key
  AiService? getServiceByKey(String modelKey, {String? apiKey}) {
    try {
      final model = AiModelExtension.fromKey(modelKey);
      return getService(model, apiKey: apiKey);
    } catch (e) {
      return null;
    }
  }

  /// Register custom service for model
  void registerService(AiModel model, AiService service) {
    _services[model] = service;
  }

  /// Clear all services
  void clearServices() {
    _services.clear();
  }

  /// Update API key for model
  void updateApiKey(AiModel model, String? apiKey) {
    if (_services.containsKey(model)) {
      _services.remove(model);
    }
    if (apiKey != null) {
      getService(model, apiKey: apiKey);
    }
  }

  /// Test connection for model
  Future<bool> testConnection(AiModel model, String apiKey) async {
    try {
      final service = getService(model, apiKey: apiKey);
      return await service.testConnection(apiKey);
    } catch (e) {
      return false;
    }
  }

  /// Get available models
  List<AiModel> getAvailableModels({String? apiKey}) {
    return AiModel.values.where((model) {
      if (model.requiresApiKey && (apiKey == null || apiKey.isEmpty)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Check if model is available
  bool isModelAvailable(AiModel model, {String? apiKey}) {
    if (model.requiresApiKey && (apiKey == null || apiKey.isEmpty)) {
      return false;
    }
    return true;
  }

  /// Get estimated response time for model
  int getEstimatedResponseTime(AiModel model, {bool deepThinking = false}) {
    final service = getService(model);
    return service.getEstimatedResponseTime(
      deepThinking: deepThinking,
      model: model,
    );
  }

  /// Get all supported models
  List<AiModel> get allSupportedModels => AiModel.values;

  /// Get models by category
  List<AiModel> getModelsByCategory(AiModelCategory category) {
    return category.models;
  }

  /// Get model display info
  Map<String, dynamic> getModelInfo(AiModel model) {
    return {
      'key': model.key,
      'displayName': model.displayName,
      'description': model.description,
      'icon': model.icon,
      'requiresApiKey': model.requiresApiKey,
      'supportsDeepThinking': model.supportsDeepThinking,
      'supportsImages': model.supportsImages,
      'supportsStreaming': model.supportsStreaming,
      'maxTokens': model.maxTokens,
      'estimatedResponseTime': model.estimatedResponseTime,
    };
  }

  /// Get all models info
  List<Map<String, dynamic>> getAllModelsInfo() {
    return allSupportedModels.map((model) => getModelInfo(model)).toList();
  }

  /// Reset factory (clears all services)
  static void reset() {
    _instance?.clearServices();
    _instance = null;
  }
}

/// Simple Local Model Service
/// Basic implementation for local/offline models
class LocalModelService implements AiService {
  @override
  String get name => 'Local Model';

  @override
  List<AiModel> get supportedModels => [AiModel.local];

  @override
  bool get isAvailable => true;

  @override
  bool get requiresApiKey => false;

  @override
  Future<String> chat(
    List<ChatMessage> messages, {
    bool deepThinking = false,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    // Simulate local model processing
    await Future.delayed(const Duration(seconds: 1));

    final lastMessage = messages.lastWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage.user(''),
    );

    return 'This is a simulated local model response. '
        'To use actual local models, integrate with TensorFlow Lite or on-device ML services.\n'
        'Your message: ${lastMessage.content}';
  }

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang, {
    bool enhanced = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return '[$sourceLang → $targetLang] $text '
        '(Simulated translation - integrate with local translation library)';
  }

  @override
  Future<List<Recommendation>> getRecommendations(
    UserContext context, {
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      Recommendation(
        id: 'local_1',
        title: 'Local Vocabulary',
        description: 'Practice vocabulary stored locally',
        type: RecommendationType.vocabulary,
        relevance: 1.0,
      ),
      Recommendation(
        id: 'local_2',
        title: 'Offline Lessons',
        description: 'Access downloaded lessons without internet',
        type: RecommendationType.general,
        relevance: 0.9,
      ),
    ];
  }

  @override
  Future<bool> testConnection(String? apiKey) async {
    // Local model is always available
    return true;
  }

  @override
  int getEstimatedResponseTime({
    bool deepThinking = false,
    AiModel? model,
  }) {
    int baseTime = model?.estimatedResponseTime ?? 2000;
    return deepThinking ? baseTime * 2 : baseTime;
  }
}

/// Mock AI Service for Testing
/// Returns predefined responses without API calls
class MockAiService implements AiService {
  @override
  String get name => 'Mock AI';

  @override
  List<AiModel> get supportedModels => AiModel.values;

  @override
  bool get isAvailable => true;

  @override
  bool get requiresApiKey => false;

  @override
  Future<String> chat(
    List<ChatMessage> messages, {
    bool deepThinking = false,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (deepThinking) {
      return '''<thinking>
Let me think about this request...

The user is asking a question. I should provide a thoughtful response.
</thinking>

This is a mock AI response for testing purposes. '
The actual AI service will be integrated when API keys are configured.''';
    }

    return 'This is a mock AI response for testing purposes. '
        'The actual AI service will be integrated when API keys are configured.';
  }

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang, {
    bool enhanced = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return '[$targetLang] $text (Mock translation)';
  }

  @override
  Future<List<Recommendation>> getRecommendations(
    UserContext context, {
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return List.generate(
      limit,
      (i) => Recommendation(
        id: 'mock_$i',
        title: 'Mock Recommendation $i',
        description: 'This is a mock recommendation for testing',
        type: RecommendationType.general,
        relevance: 1.0 - (i * 0.1),
      ),
    );
  }

  @override
  Future<bool> testConnection(String? apiKey) async {
    return true;
  }

  @override
  int getEstimatedResponseTime({
    bool deepThinking = false,
    AiModel? model,
  }) {
    return 500;
  }
}
