import '../models/chat_message.dart';
import '../models/ai_model.dart';

/// AI Service Interface
/// Defines the contract for all AI service implementations
abstract class AiService {
  /// Get the service name
  String get name;

  /// Get supported models
  List<AiModel> get supportedModels;

  /// Check if service is available
  bool get isAvailable;

  /// Check if API key is required
  bool get requiresApiKey;

  /// Chat completion
  /// Returns AI response to the given messages
  Future<String> chat(
    List<ChatMessage> messages, {
    bool deepThinking = false,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  });

  /// Translate text
  /// Translates text from source language to target language
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang, {
    bool enhanced = false,
  });

  /// Get recommendations
  /// Returns personalized recommendations based on user context
  Future<List<Recommendation>> getRecommendations(
    UserContext context, {
    int limit = 5,
  });

  /// Test connection
  /// Returns true if the service is properly configured and accessible
  Future<bool> testConnection(String? apiKey);

  /// Get estimated response time in milliseconds
  int getEstimatedResponseTime({
    bool deepThinking = false,
    AiModel? model,
  });
}

/// Recommendation Model
/// Represents a single recommendation item
class Recommendation {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? actionUrl;
  final RecommendationType type;
  final double relevance;
  final Map<String, dynamic>? metadata;

  const Recommendation({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.actionUrl,
    required this.type,
    required this.relevance,
    this.metadata,
  });

  /// Create from JSON
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      actionUrl: json['actionUrl'] as String?,
      type: RecommendationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RecommendationType.general,
      ),
      relevance: (json['relevance'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'type': type.name,
      'relevance': relevance,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'Recommendation(id: $id, title: $title, type: ${type.name}, relevance: $relevance)';
  }
}

/// Recommendation Type Enum
enum RecommendationType {
  translation,
  vocabulary,
  grammar,
  practice,
  general,
}

/// User Context for Recommendations
/// Contains user information for generating personalized recommendations
class UserContext {
  final String? userId;
  final List<String> interests;
  final List<String> recentActivities;
  final Map<String, dynamic>? preferences;
  final String? currentLanguage;
  final String? targetLanguage;
  final int? proficiencyLevel; // 1-5

  const UserContext({
    this.userId,
    this.interests = const [],
    this.recentActivities = const [],
    this.preferences,
    this.currentLanguage,
    this.targetLanguage,
    this.proficiencyLevel,
  });

  /// Create empty context
  const UserContext.empty()
      : userId = null,
        interests = const [],
        recentActivities = const [],
        preferences = null,
        currentLanguage = null,
        targetLanguage = null,
        proficiencyLevel = null;

  /// Copy with method
  UserContext copyWith({
    String? userId,
    List<String>? interests,
    List<String>? recentActivities,
    Map<String, dynamic>? preferences,
    String? currentLanguage,
    String? targetLanguage,
    int? proficiencyLevel,
  }) {
    return UserContext(
      userId: userId ?? this.userId,
      interests: interests ?? this.interests,
      recentActivities: recentActivities ?? this.recentActivities,
      preferences: preferences ?? this.preferences,
      currentLanguage: currentLanguage ?? this.currentLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
    );
  }

  @override
  String toString() {
    return 'UserContext(userId: $userId, interests: ${interests.join(', ')}, '
        'currentLanguage: $currentLanguage, targetLanguage: $targetLanguage, '
        'proficiencyLevel: $proficiencyLevel)';
  }
}

/// AI Service Exception
/// Thrown when AI service encounters an error
class AiServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AiServiceException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AiServiceException: $message');
    if (statusCode != null) {
      buffer.write(' (status code: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }

  /// Create from HTTP error
  factory AiServiceException.fromHttpError(
    int statusCode,
    String message,
  ) {
    return AiServiceException(
      message,
      statusCode: statusCode,
    );
  }

  /// Create from network error
  factory AiServiceException.networkError(String message, [dynamic error]) {
    return AiServiceException(
      'Network error: $message',
      originalError: error,
    );
  }

  /// Create from API key error
  factory AiServiceException.invalidApiKey() {
    return const AiServiceException(
      'Invalid API key. Please check your API key configuration.',
      statusCode: 401,
    );
  }

  /// Create from rate limit error
  factory AiServiceException.rateLimitExceeded() {
    return const AiServiceException(
      'Rate limit exceeded. Please try again later.',
      statusCode: 429,
    );
  }

  /// Create from quota exceeded error
  factory AiServiceException.quotaExceeded() {
    return const AiServiceException(
      'API quota exceeded. Please check your plan.',
      statusCode: 402,
    );
  }

  /// Create from model not available error
  factory AiServiceException.modelNotAvailable(String modelName) {
    return AiServiceException(
      'Model $modelName is not available. Please select a different model.',
    );
  }
}
