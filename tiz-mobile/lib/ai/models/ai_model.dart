/// AI Model Enum
/// Defines all supported AI models
enum AiModel {
  gpt4,
  gpt35,
  claude,
  gemini,
  local,
  custom,
}

/// AI Model Extension
extension AiModelExtension on AiModel {
  /// Get model display name
  String get displayName {
    switch (this) {
      case AiModel.gpt4:
        return 'GPT-4';
      case AiModel.gpt35:
        return 'GPT-3.5 Turbo';
      case AiModel.claude:
        return 'Claude 3 Opus';
      case AiModel.gemini:
        return 'Gemini Pro';
      case AiModel.local:
        return 'Local Model';
      case AiModel.custom:
        return 'Custom API';
    }
  }

  /// Get model description
  String get description {
    switch (this) {
      case AiModel.gpt4:
        return 'Complex reasoning, enhanced translation';
      case AiModel.gpt35:
        return 'Fast responses, simple Q&A';
      case AiModel.claude:
        return 'Long-text analysis, document translation';
      case AiModel.gemini:
        return 'Multimodal, image translation';
      case AiModel.local:
        return 'Privacy-preserving, offline';
      case AiModel.custom:
        return 'Private deployment, third-party';
    }
  }

  /// Get model key for storage
  String get key {
    switch (this) {
      case AiModel.gpt4:
        return 'gpt4';
      case AiModel.gpt35:
        return 'gpt35';
      case AiModel.claude:
        return 'claude';
      case AiModel.gemini:
        return 'gemini';
      case AiModel.local:
        return 'local';
      case AiModel.custom:
        return 'custom';
    }
  }

  /// Get model from key
  static AiModel fromKey(String key) {
    return AiModel.values.firstWhere(
      (model) => model.key == key,
      orElse: () => AiModel.gpt35,
    );
  }

  /// Check if model requires API key
  bool get requiresApiKey {
    switch (this) {
      case AiModel.local:
        return false;
      default:
        return true;
    }
  }

  /// Check if model supports deep thinking mode
  bool get supportsDeepThinking {
    switch (this) {
      case AiModel.gpt4:
      case AiModel.claude:
        return true;
      default:
        return false;
    }
  }

  /// Get model icon
  String get icon {
    switch (this) {
      case AiModel.gpt4:
      case AiModel.gpt35:
        return '🧠';
      case AiModel.claude:
        return '💭';
      case AiModel.gemini:
        return '✨';
      case AiModel.local:
        return '🔒';
      case AiModel.custom:
        return '⚙️';
    }
  }

  /// Get estimated response time (milliseconds)
  int get estimatedResponseTime {
    switch (this) {
      case AiModel.gpt4:
        return 1500;
      case AiModel.gpt35:
        return 500;
      case AiModel.claude:
        return 1200;
      case AiModel.gemini:
        return 800;
      case AiModel.local:
        return 2000;
      case AiModel.custom:
        return 1000;
    }
  }

  /// Get max tokens limit
  int get maxTokens {
    switch (this) {
      case AiModel.gpt4:
        return 8192;
      case AiModel.gpt35:
        return 4096;
      case AiModel.claude:
        return 100000;
      case AiModel.gemini:
        return 32768;
      case AiModel.local:
        return 2048;
      case AiModel.custom:
        return 4096;
    }
  }

  /// Check if model supports image input
  bool get supportsImages {
    switch (this) {
      case AiModel.gemini:
      case AiModel.gpt4:
        return true;
      default:
        return false;
    }
  }

  /// Check if model supports streaming
  bool get supportsStreaming {
    switch (this) {
      case AiModel.local:
        return false;
      default:
        return true;
    }
  }
}

/// AI Model Category
enum AiModelCategory {
  openai,
  anthropic,
  google,
  local,
  custom,
}

/// AI Model Category Extension
extension AiModelCategoryExtension on AiModelCategory {
  String get displayName {
    switch (this) {
      case AiModelCategory.openai:
        return 'OpenAI';
      case AiModelCategory.anthropic:
        return 'Anthropic';
      case AiModelCategory.google:
        return 'Google';
      case AiModelCategory.local:
        return 'Local';
      case AiModelCategory.custom:
        return 'Custom';
    }
  }

  List<AiModel> get models {
    switch (this) {
      case AiModelCategory.openai:
        return [AiModel.gpt4, AiModel.gpt35];
      case AiModelCategory.anthropic:
        return [AiModel.claude];
      case AiModelCategory.google:
        return [AiModel.gemini];
      case AiModelCategory.local:
        return [AiModel.local];
      case AiModelCategory.custom:
        return [AiModel.custom];
    }
  }
}
