import 'package:uuid/uuid.dart';

/// Chat Message Role
enum MessageRole {
  user,
  assistant,
  system,
}

/// Chat Message Model
/// Represents a single message in the chat conversation
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isDeepThinking;
  final String? thinkingProcess;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isDeepThinking = false,
    this.thinkingProcess,
    this.metadata,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// Create user message
  factory ChatMessage.user(String content, {Map<String, dynamic>? metadata}) {
    return ChatMessage(
      role: MessageRole.user,
      content: content,
      metadata: metadata,
    );
  }

  /// Create assistant message
  factory ChatMessage.assistant(
    String content, {
    bool isDeepThinking = false,
    String? thinkingProcess,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      role: MessageRole.assistant,
      content: content,
      isDeepThinking: isDeepThinking,
      thinkingProcess: thinkingProcess,
      metadata: metadata,
    );
  }

  /// Create system message
  factory ChatMessage.system(String content) {
    return ChatMessage(
      role: MessageRole.system,
      content: content,
    );
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      isDeepThinking: json['isDeepThinking'] as bool? ?? false,
      thinkingProcess: json['thinkingProcess'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isDeepThinking': isDeepThinking,
      'thinkingProcess': thinkingProcess,
      'metadata': metadata,
    };
  }

  /// Convert to API format (for OpenAI, Claude, etc.)
  Map<String, dynamic> toApiFormat() {
    return {
      'role': role.name,
      'content': content,
    };
  }

  /// Copy with method
  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
    bool? isDeepThinking,
    String? thinkingProcess,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isDeepThinking: isDeepThinking ?? this.isDeepThinking,
      thinkingProcess: thinkingProcess ?? this.thinkingProcess,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Check if message is from user
  bool get isUser => role == MessageRole.user;

  /// Check if message is from assistant
  bool get isAssistant => role == MessageRole.assistant;

  /// Check if message is a system message
  bool get isSystem => role == MessageRole.system;

  /// Get formatted timestamp
  String get formattedTime {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  String toString() {
    return 'ChatMessage(role: ${role.name}, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.id == id &&
        other.role == role &&
        other.content == content &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        role.hashCode ^
        content.hashCode ^
        timestamp.hashCode;
  }
}

/// Chat Session Model
/// Represents a complete chat conversation session
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final bool isPinned;

  ChatSession({
    String? id,
    required this.title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    this.lastUpdatedAt,
    this.isPinned = false,
  }) : id = id ?? const Uuid().v4(),
       messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'] as String)
          : null,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'isPinned': isPinned,
    };
  }

  /// Add a message to the session
  ChatSession addMessage(ChatMessage message) {
    return ChatSession(
      id: id,
      title: title,
      messages: [...messages, message],
      createdAt: createdAt,
      lastUpdatedAt: DateTime.now(),
      isPinned: isPinned,
    );
  }

  /// Get messages for API (exclude system messages unless needed)
  List<Map<String, dynamic>> get messagesForApi {
    return messages
        .where((m) => !m.isSystem)
        .map((m) => m.toApiFormat())
        .toList();
  }

  /// Get last message
  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Get message count
  int get messageCount => messages.length;

  /// Copy with method
  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    bool? isPinned,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  String toString() {
    return 'ChatSession(id: $id, title: $title, messageCount: $messageCount)';
  }
}

/// Thinking Response Model
/// Represents AI response with thinking process
class ThinkingResponse {
  final String thinkingProcess;
  final String conclusion;

  const ThinkingResponse({
    required this.thinkingProcess,
    required this.conclusion,
  });

  /// Create from API response
  factory ThinkingResponse.fromResponse(String fullResponse) {
    // Try to parse thinking process from response
    // Format: <thinking>...</thinking>\n\n<conclusion>...</conclusion>
    final thinkingRegex = RegExp(r'<thinking>(.*?)</thinking>', dotAll: true);
    final thinkingMatch = thinkingRegex.firstMatch(fullResponse);

    if (thinkingMatch != null) {
      final thinking = thinkingMatch.group(1) ?? '';
      final conclusion = fullResponse.replaceFirst(thinkingMatch.group(0)!, '').trim();
      return ThinkingResponse(
        thinkingProcess: thinking,
        conclusion: conclusion,
      );
    }

    // If no thinking tags, treat entire response as conclusion
    return ThinkingResponse(
      thinkingProcess: '',
      conclusion: fullResponse,
    );
  }

  /// Format thinking process for display
  String get formattedThinking {
    if (thinkingProcess.isEmpty) return '';

    // Format thinking process with bullet points
    final lines = thinkingProcess.split('\n');
    final formatted = lines.map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed.startsWith('-')) return '  $trimmed';
      if (trimmed.startsWith(RegExp(r'^\d+\.'))) return '  $trimmed';
      return '• $trimmed';
    }).join('\n');

    return formatted;
  }

  /// Get full formatted response
  String get fullResponse {
    if (thinkingProcess.isEmpty) {
      return conclusion;
    }
    return '<thinking>$thinkingProcess</thinking>\n\n$conclusion';
  }

  @override
  String toString() {
    return 'ThinkingResponse(thinking: ${thinkingProcess.substring(0, thinkingProcess.length > 50 ? 50 : thinkingProcess.length)}..., '
        'conclusion: ${conclusion.substring(0, conclusion.length > 50 ? 50 : conclusion.length)}...)';
  }
}
