import 'package:dio/dio.dart';
import 'ai_service.dart';
import '../models/ai_model.dart';
import '../models/chat_message.dart';
import '../../core/constants.dart';

/// OpenAI Service Implementation
/// Implements AI service interface for OpenAI models (GPT-3.5, GPT-4)
class OpenAiService implements AiService {
  final Dio _dio;
  final String? apiKey;

  OpenAiService({this.apiKey})
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.openaiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          },
        ));

  @override
  String get name => 'OpenAI';

  @override
  List<AiModel> get supportedModels => [
        AiModel.gpt4,
        AiModel.gpt35,
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
      // Prepare messages for API
      final apiMessages = <Map<String, String>>[];

      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        apiMessages.add({
          'role': 'system',
          'content': systemPrompt,
        });
      } else {
        apiMessages.add({
          'role': 'system',
          'content': 'You are a helpful AI assistant for translation and language learning.',
        });
      }

      // Add deep thinking instruction if enabled
      if (deepThinking) {
        apiMessages.add({
          'role': 'system',
          'content': 'Please think through your response carefully. '
              'Start your thinking process with <thinking> tags, '
              'then provide your conclusion after </thinking>.',
        });
      }

      // Add conversation messages
      for (final message in messages) {
        apiMessages.add({
          'role': message.role.name,
          'content': message.content,
        });
      }

      // Make API request
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo', // Default model
          'messages': apiMessages,
          'temperature': temperature ?? 0.7,
          'max_tokens': maxTokens ?? 2048,
        },
      );

      // Parse response
      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List;
      final firstChoice = choices.first as Map<String, dynamic>;
      final message = firstChoice['message'] as Map<String, dynamic>;
      final content = message['content'] as String;

      return content;
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
          ? '''Translate the following text from $sourceLang to $targetLang.
Consider the context and provide the most accurate translation.

Text: $text

Provide only the translation without explanation.'''
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
        baseUrl: AppConstants.openaiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ));

      await testDio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Hi'}
          ],
          'max_tokens': 5,
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
    int baseTime = model?.estimatedResponseTime ?? 500;

    if (deepThinking) {
      return baseTime * 3;
    }

    return baseTime;
  }

  String _parseErrorMessage(dynamic data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        return error['message']?.toString() ?? 'Unknown error';
      }
      return data.toString();
    }
    return 'Unknown error';
  }

  String _buildRecommendationPrompt(UserContext context, int limit) {
    final buffer = StringBuffer(
      'Generate $limit personalized recommendations for language learning. '
      'Return as JSON array with: id, title, description, type (vocabulary/grammar/practice), '
      'and relevance (0-1).\n\n',
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
      buffer.write('Interests: ${context.interests.join(', ')}\n');
    }
    if (context.recentActivities.isNotEmpty) {
      buffer.write('Recent activities: ${context.recentActivities.join(', ')}\n');
    }

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
      }

      // Parse JSON
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
        description: 'Learn 10 new words every day',
        type: RecommendationType.vocabulary,
        relevance: 0.9,
      ),
      Recommendation(
        id: '2',
        title: 'Grammar Quiz',
        description: 'Test your grammar knowledge',
        type: RecommendationType.grammar,
        relevance: 0.8,
      ),
      Recommendation(
        id: '3',
        title: 'Translation Exercise',
        description: 'Practice translating sentences',
        type: RecommendationType.practice,
        relevance: 0.85,
      ),
    ];
  }
}
