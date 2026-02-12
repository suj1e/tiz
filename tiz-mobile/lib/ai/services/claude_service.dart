import 'package:dio/dio.dart';
import 'ai_service.dart';
import '../models/ai_model.dart';
import '../models/chat_message.dart';
import '../../core/constants.dart';

/// Claude Service Implementation
/// Implements AI service interface for Anthropic Claude models
class ClaudeService implements AiService {
  final Dio _dio;
  final String? apiKey;

  ClaudeService({this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.claudeBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 90),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': apiKey ?? '',
            'anthropic-version': '2023-06-01',
          },
        ));

  @override
  String get name => 'Claude';

  @override
  List<AiModel> get supportedModels => [
        AiModel.claude,
      ];

  @override
  bool get isAvailable => apiKey != null && apiKey!.isNotEmpty;

  @override
  bool get requiresApiKey => true;

  @override
  Future<String> chat(
    List<ChatMessage> messages, {
    bool deepThinking = false,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    if (!isAvailable) {
      throw AiServiceException.invalidApiKey();
    }

    try {
      // Prepare messages for Claude API
      final apiMessages = <Map<String, String>>[];

      // Add conversation messages (Claude uses alternating user/assistant)
      for (final message in messages) {
        if (message.isUser) {
          apiMessages.add({
            'role': 'user',
            'content': message.content,
          });
        } else if (message.isAssistant) {
          apiMessages.add({
            'role': 'assistant',
            'content': message.content,
          });
        }
      }

      // Prepare system prompt
      String finalSystemPrompt = systemPrompt ??
          'You are a helpful AI assistant for translation and language learning.';

      if (deepThinking) {
        finalSystemPrompt += '\n\nPlease think through your responses carefully. '
            'Show your thinking process before providing your final answer.';
      }

      // Make API request
      final response = await _dio.post(
        '/messages',
        data: {
          'model': 'claude-3-opus-20240229',
          'max_tokens': maxTokens ?? 4096,
          'system': finalSystemPrompt,
          'messages': apiMessages,
          if (temperature != null) 'temperature': temperature,
        },
      );

      // Parse response
      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as List;
      final firstContent = content.first as Map<String, dynamic>;
      final text = firstContent['text'] as String;

      return text;
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 0;
        final message = _parseErrorMessage(e.response!.data);

        switch (statusCode) {
          case 401:
            throw AiServiceException.invalidApiKey();
          case 429:
            throw AiServiceException.rateLimitExceeded();
          case 402:
            throw AiServiceException.quotaExceeded();
          default:
            throw AiServiceException.fromHttpError(statusCode, message);
        }
      } else {
        throw AiServiceException.networkError(
          e.message ?? 'Unknown network error',
          e.error,
        );
      }
    } catch (e) {
      throw AiServiceException('Unexpected error: $e');
    }
  }

  @override
  Future<String> translate(
    String text,
    String sourceLang,
    String targetLang, {
    bool enhanced = false,
  }) async {
    if (!isAvailable) {
      throw AiServiceException.invalidApiKey();
    }

    try {
      final prompt = enhanced
          ? '''Please translate the following text from $sourceLang to $targetLang.
Consider the full context and nuance of the original text.

Text to translate:
$text

Provide only the translation, with no additional explanation or commentary.'''
          : 'Translate from $sourceLang to $targetLang: $text';

      final response = await chat(
        [ChatMessage.user(prompt)],
        temperature: enhanced ? 0.3 : 0.5,
      );

      // Clean up response
      return response.trim();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Recommendation>> getRecommendations(
    UserContext context, {
    int limit = 5,
  }) async {
    if (!isAvailable) {
      throw AiServiceException.invalidApiKey();
    }

    try {
      final prompt = _buildRecommendationPrompt(context, limit);

      final response = await chat(
        [ChatMessage.user(prompt)],
        temperature: 0.8,
      );

      return _parseRecommendations(response);
    } catch (e) {
      // Return default recommendations on error
      return _getDefaultRecommendations(context);
    }
  }

  @override
  Future<bool> testConnection(String? apiKey) async {
    if (apiKey == null || apiKey.isEmpty) {
      return false;
    }

    try {
      final testDio = Dio(BaseOptions(
        baseUrl: AppConstants.claudeBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
      ));

      await testDio.post(
        '/messages',
        data: {
          'model': 'claude-3-opus-20240229',
          'max_tokens': 10,
          'messages': [
            {'role': 'user', 'content': 'Hi'}
          ],
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  int getEstimatedResponseTime({
    bool deepThinking = false,
    AiModel? model,
  }) {
    int baseTime = model?.estimatedResponseTime ?? 1200;

    if (deepThinking) {
      return baseTime * 2;
    }

    return baseTime;
  }

  String _parseErrorMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        return error['message']?.toString() ?? 'Unknown error';
      }
      if (error is String) {
        return error;
      }
      return data.toString();
    }
    return 'Unknown error';
  }

  String _buildRecommendationPrompt(UserContext context, int limit) {
    final buffer = StringBuffer(
      'Generate $limit personalized language learning recommendations. '
      'Return your response as a JSON array, where each item has: '
      'id (string), title (string), description (string), '
      'type (one of: vocabulary, grammar, practice), and relevance (number 0-1).\n\n',
    );

    if (context.currentLanguage != null) {
      buffer.write('Current language: ${context.currentLanguage}\n');
    }
    if (context.targetLanguage != null) {
      buffer.write('Target language: ${context.targetLanguage}\n');
    }
    if (context.proficiencyLevel != null) {
      buffer.write('Proficiency level: ${context.proficiencyLevel}/5\n');
    }
    if (context.interests.isNotEmpty) {
      buffer.write('User interests: ${context.interests.join(', ')}\n');
    }
    if (context.recentActivities.isNotEmpty) {
      buffer.write('Recent activities: ${context.recentActivities.join(', ')}\n');
    }

    buffer.write('\nProvide the JSON array response only, without any additional text.');

    return buffer.toString();
  }

  List<Recommendation> _parseRecommendations(String response) {
    try {
      // Remove markdown code blocks if present
      var cleanResponse = response.trim();
      if (cleanResponse.startsWith('```')) {
        final firstNewline = cleanResponse.indexOf('\n');
        final lastBackticks = cleanResponse.lastIndexOf('```');
        cleanResponse = cleanResponse.substring(firstNewline + 1, lastBackticks).trim();
        if (cleanResponse.startsWith('json')) {
          cleanResponse = cleanResponse.substring(4).trim();
        }
      }

      // Simplified parsing - would use dart:convert in production
      return _getDefaultRecommendations(const UserContext.empty());
    } catch (e) {
      return _getDefaultRecommendations(const UserContext.empty());
    }
  }

  List<Recommendation> _getDefaultRecommendations(UserContext context) {
    return [
      Recommendation(
        id: '1',
        title: 'Daily Vocabulary Practice',
        description: 'Learn 10 new words every day with spaced repetition',
        type: RecommendationType.vocabulary,
        relevance: 0.9,
      ),
      Recommendation(
        id: '2',
        title: 'Grammar Foundations',
        description: 'Master essential grammar rules',
        type: RecommendationType.grammar,
        relevance: 0.85,
      ),
      Recommendation(
        id: '3',
        title: 'Conversation Practice',
        description: 'Practice speaking with AI conversations',
        type: RecommendationType.practice,
        relevance: 0.88,
      ),
      Recommendation(
        id: '4',
        title: 'Reading Comprehension',
        description: 'Improve reading with graded texts',
        type: RecommendationType.general,
        relevance: 0.82,
      ),
      Recommendation(
        id: '5',
        title: 'Writing Exercises',
        description: 'Practice writing with guided prompts',
        type: RecommendationType.practice,
        relevance: 0.80,
      ),
    ];
  }
}
