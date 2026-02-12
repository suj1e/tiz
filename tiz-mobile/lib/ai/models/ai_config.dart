import 'ai_model.dart';

/// AI Configuration Data Class
/// Stores all AI-related settings and preferences
class AiConfig {
  final AiModel model;
  final String? apiKey;
  final double temperature;
  final int maxTokens;
  final String systemPrompt;
  final bool enhanceTranslation;
  final bool smartRecommend;
  final bool voiceAssistant;
  final bool deepThinkingMode;
  final bool streamOutput;
  final DateTime? lastUpdated;

  const AiConfig({
    required this.model,
    this.apiKey,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.systemPrompt = 'You are a helpful AI assistant.',
    this.enhanceTranslation = true,
    this.smartRecommend = true,
    this.voiceAssistant = false,
    this.deepThinkingMode = false,
    this.streamOutput = true,
    this.lastUpdated,
  });

  /// Default configuration
  factory AiConfig.defaultConfig() {
    return const AiConfig(
      model: AiModel.gpt35,
      temperature: 0.7,
      maxTokens: 2048,
      systemPrompt: 'You are a helpful AI assistant.',
      enhanceTranslation: true,
      smartRecommend: true,
      voiceAssistant: false,
      deepThinkingMode: false,
      streamOutput: true,
    );
  }

  /// Create from JSON
  factory AiConfig.fromJson(Map<String, dynamic> json) {
    return AiConfig(
      model: AiModelExtension.fromKey(json['model'] as String? ?? 'gpt35'),
      apiKey: json['apiKey'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 2048,
      systemPrompt: json['systemPrompt'] as String? ??
          'You are a helpful AI assistant.',
      enhanceTranslation: json['enhanceTranslation'] as bool? ?? true,
      smartRecommend: json['smartRecommend'] as bool? ?? true,
      voiceAssistant: json['voiceAssistant'] as bool? ?? false,
      deepThinkingMode: json['deepThinkingMode'] as bool? ?? false,
      streamOutput: json['streamOutput'] as bool? ?? true,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'model': model.key,
      'apiKey': apiKey,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'systemPrompt': systemPrompt,
      'enhanceTranslation': enhanceTranslation,
      'smartRecommend': smartRecommend,
      'voiceAssistant': voiceAssistant,
      'deepThinkingMode': deepThinkingMode,
      'streamOutput': streamOutput,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Copy with method for immutability
  AiConfig copyWith({
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
    DateTime? lastUpdated,
  }) {
    return AiConfig(
      model: model ?? this.model,
      apiKey: apiKey ?? this.apiKey,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      enhanceTranslation: enhanceTranslation ?? this.enhanceTranslation,
      smartRecommend: smartRecommend ?? this.smartRecommend,
      voiceAssistant: voiceAssistant ?? this.voiceAssistant,
      deepThinkingMode: deepThinkingMode ?? this.deepThinkingMode,
      streamOutput: streamOutput ?? this.streamOutput,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if API key is configured
  bool get isApiKeyConfigured {
    return model.requiresApiKey && apiKey != null && apiKey!.isNotEmpty;
  }

  /// Check if ready to use
  bool get isReady {
    if (model.requiresApiKey) {
      return apiKey != null && apiKey!.isNotEmpty;
    }
    return true;
  }

  /// Get actual max tokens (respect model limit)
  int get effectiveMaxTokens {
    return maxTokens <= model.maxTokens ? maxTokens : model.maxTokens;
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(AiFeature feature) {
    switch (feature) {
      case AiFeature.enhanceTranslation:
        return enhanceTranslation;
      case AiFeature.smartRecommend:
        return smartRecommend;
      case AiFeature.voiceAssistant:
        return voiceAssistant;
      case AiFeature.deepThinkingMode:
        return deepThinkingMode && model.supportsDeepThinking;
    }
  }

  @override
  String toString() {
    return 'AiConfig(model: ${model.displayName}, '
        'temperature: $temperature, '
        'maxTokens: $maxTokens, '
        'enhanceTranslation: $enhanceTranslation, '
        'smartRecommend: $smartRecommend, '
        'voiceAssistant: $voiceAssistant, '
        'deepThinkingMode: $deepThinkingMode, '
        'streamOutput: $streamOutput)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AiConfig &&
        other.model == model &&
        other.apiKey == apiKey &&
        other.temperature == temperature &&
        other.maxTokens == maxTokens &&
        other.systemPrompt == systemPrompt &&
        other.enhanceTranslation == enhanceTranslation &&
        other.smartRecommend == smartRecommend &&
        other.voiceAssistant == voiceAssistant &&
        other.deepThinkingMode == deepThinkingMode &&
        other.streamOutput == streamOutput;
  }

  @override
  int get hashCode {
    return model.hashCode ^
        apiKey.hashCode ^
        temperature.hashCode ^
        maxTokens.hashCode ^
        systemPrompt.hashCode ^
        enhanceTranslation.hashCode ^
        smartRecommend.hashCode ^
        voiceAssistant.hashCode ^
        deepThinkingMode.hashCode ^
        streamOutput.hashCode;
  }
}

/// AI Feature Enum
enum AiFeature {
  enhanceTranslation,
  smartRecommend,
  voiceAssistant,
  deepThinkingMode,
}

/// AI Feature Extension
extension AiFeatureExtension on AiFeature {
  String get displayName {
    switch (this) {
      case AiFeature.enhanceTranslation:
        return 'AI增强翻译';
      case AiFeature.smartRecommend:
        return 'AI智能推荐';
      case AiFeature.voiceAssistant:
        return 'AI语音助手';
      case AiFeature.deepThinkingMode:
        return '深度思考模式';
    }
  }

  String get description {
    switch (this) {
      case AiFeature.enhanceTranslation:
        return '使用AI增强翻译结果的准确性';
      case AiFeature.smartRecommend:
        return '根据使用习惯推荐相关内容';
      case AiFeature.voiceAssistant:
        return '通过语音与AI助手交互';
      case AiFeature.deepThinkingMode:
        return '启用深度思考，获得更详细的分析';
    }
  }

  String get icon {
    switch (this) {
      case AiFeature.enhanceTranslation:
        return 'translate';
      case AiFeature.smartRecommend:
        return 'auto_awesome';
      case AiFeature.voiceAssistant:
        return 'mic';
      case AiFeature.deepThinkingMode:
        return 'psychology';
    }
  }
}
