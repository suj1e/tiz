# Tiz Mobile App - Mock Data Documentation

**Version:** 1.0.0
**Last Updated:** 2026-02-08

---

## Overview

This document describes the mock data structures and API responses used in the Tiz mobile app. The app currently uses mock data for development and testing purposes.

---

## Authentication Mock Data

### Login Response

**Mock Validation Rules:**
- Email must contain "@"
- Password length must be > 6 characters

**Success Response:**
```dart
{
  "success": true,
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "name": "User Name"
  },
  "token": "mock_jwt_token"
}
```

**Error Responses:**
```dart
// Invalid email
{
  "success": false,
  "error": "请输入有效的邮箱地址"
}

// Invalid password
{
  "success": false,
  "error": "密码长度必须大于6个字符"
}
```

---

### Register Response

**Mock Validation Rules:**
- All fields required
- Email must contain "@"
- Password length must be > 6 characters
- Password and confirmPassword must match

**Success Response:**
```dart
{
  "success": true,
  "user": {
    "id": "user_456",
    "email": "john@example.com",
    "name": "John Doe"
  },
  "token": "mock_jwt_token"
}
```

**Error Responses:**
```dart
// Empty name
{
  "success": false,
  "error": "请输入姓名"
}

// Invalid email
{
  "success": false,
  "error": "请输入有效的邮箱地址"
}

// Short password
{
  "success": false,
  "error": "密码长度必须大于6个字符"
}

// Password mismatch
{
  "success": false,
  "error": "两次输入的密码不一致"
}
```

---

### User Session Model

Located at `lib/features/auth/auth_controller.dart`:

```dart
class AuthController extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _currentUserEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;

  Future<bool> login(String email, String password);
  Future<bool> register(String name, String email, String password, String confirmPassword);
  void logout();
}
```

**Mock Session Data:**
```dart
{
  "id": "session_789",
  "email": "user@example.com",
  "name": "User Name",
  "token": "mock_jwt_token",
  "createdAt": "2026-02-08T10:00:00Z",
  "isActive": true
}
```

---

## Quiz Mock Data

### Quiz Question Model

Located at `lib/quiz/models.dart`:

```dart
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final QuizDifficulty difficulty;
}

enum QuizDifficulty {
  beginner,
  intermediate,
  advanced,
}
```

---

### Quiz Session Model

```dart
class QuizSession {
  final String id;
  final List<QuizQuestion> questions;
  final QuizMode mode;
  final QuizCategory category;
  final DateTime startedAt;

  int currentIndex;
  int score;
  List<int?> userAnswers;
  bool isCompleted;

  // Get current question
  QuizQuestion? get currentQuestion;

  // Get progress (0.0 to 1.0)
  double get progress;

  // Submit answer for current question
  void submitAnswer(int answerIndex);

  // Calculate percentage score
  double get percentage;

  // Check if user passed (60% or higher)
  bool get passed;
}

enum QuizMode {
  choice,        // Multiple choice
  conversation,  // Text-based Q&A
  voiceCall,     // Voice call
}

enum QuizCategory {
  english,
  japanese,
  german,
}
```

---

### Mock Questions Data

Located at `lib/quiz/models.dart` (lines 109-246):

**English Questions (5 total):**

1. **Beginner**: "What is the past tense of 'go'?"
   - Options: ["A. goed", "B. went", "C. gone", "D. goes"]
   - Correct: 1 (B)
   - Explanation: "Went" is the irregular past tense of "go".

2. **Beginner**: "Which word is a synonym for 'happy'?"
   - Options: ["A. sad", "B. joyful", "C. angry", "D. tired"]
   - Correct: 1 (B)
   - Explanation: "Joyful" means experiencing or showing great pleasure.

3. **Intermediate**: "Choose the correct sentence:"
   - Options: ["A. She don't like coffee.", "B. She doesn't likes coffee.", "C. She doesn't like coffee.", "D. She not like coffee."]
   - Correct: 2 (C)
   - Explanation: The correct form is "doesn't like" for third person singular.

4. **Advanced**: "What does 'ubiquitous' mean?"
   - Options: ["A. Rare", "B. Present everywhere", "C. Ancient", "D. Modern"]
   - Correct: 1 (B)
   - Explanation: "Ubiquitous" means appearing or found everywhere.

5. **Intermediate**: "Fill in the blank: 'I look forward _____ from you.'"
   - Options: ["A. to hear", "B. to hearing", "C. hearing", "D. hear"]
   - Correct: 1 (B)
   - Explanation: The phrase is "look forward to", and it's followed by the gerund "hearing".

**Japanese Questions (5 total):**

1. **Beginner**: "What does 'こんにちは' (konnichiwa) mean?"
   - Options: ["A. Good morning", "B. Hello", "C. Goodbye", "D. Thank you"]
   - Correct: 1 (B)
   - Explanation: "Konnichiwa" is the standard daytime greeting meaning "hello".

2. **Beginner**: "How do you say 'thank you' in Japanese?"
   - Options: ["A. すみません", "B. ありがとうございます", "C. はい", "D. いいえ"]
   - Correct: 1 (B)
   - Explanation: "Arigatou gozaimasu" is the polite way to say thank you.

3. **Intermediate**: "What is the Hiragana for 'sakura' (cherry blossom)?"
   - Options: ["A. さくら", "B. さきら", "C. さくれ", "D. さきり"]
   - Correct: 0 (A)
   - Explanation: "Sakura" is written as さくら in Hiragana.

4. **Intermediate**: "What does '日本' mean?"
   - Options: ["A. China", "B. Korea", "C. Japan", "D. Vietnam"]
   - Correct: 2 (C)
   - Explanation: "日本" (Nihon/Nippon) means Japan, the land of the rising sun.

5. **Advanced**: "Which particle indicates the topic of a sentence?"
   - Options: ["A. は (wa)", "B. が (ga)", "C. を (wo)", "D. に (ni)"]
   - Correct: 0 (A)
   - Explanation: The particle "は" (wa) marks the topic of the sentence.

**German Questions (5 total):**

1. **Beginner**: "What does 'Guten Tag' mean?"
   - Options: ["A. Goodbye", "B. Good day", "C. Good night", "D. Thank you"]
   - Correct: 1 (B)
   - Explanation: "Guten Tag" is a formal daytime greeting meaning "good day".

2. **Beginner**: "How do you say 'yes' in German?"
   - Options: ["A. Nein", "B. Ja", "C. Vielleicht", "D. Bitte"]
   - Correct: 1 (B)
   - Explanation: "Ja" means "yes" in German.

3. **Intermediate**: "What is the definite article for 'Tisch' (table)?"
   - Options: ["A. die", "B. der", "C. das", "D. den"]
   - Correct: 1 (B)
   - Explanation: "Tisch" is masculine, so it uses "der".

4. **Intermediate**: "What does 'Ich liebe dich' mean?"
   - Options: ["A. I like you", "B. I love you", "C. I hate you", "D. I miss you"]
   - Correct: 1 (B)
   - Explanation: "Ich liebe dich" means "I love you" in German.

5. **Intermediate**: "Which verb form is used for 'I go'?"
   - Options: ["A. gehe", "B. gehst", "C. geht", "D. gehen"]
   - Correct: 0 (A)
   - Explanation: "Ich gehe" uses the first person singular form "gehe".

---

## Translation Mock Data

### Translation History Model

```dart
class TranslationHistoryItem {
  String id;
  String sourceText;
  String translatedText;
  String sourceLanguage;
  String targetLanguage;
  DateTime timestamp;

  // Format timestamp for display
  String get formattedTime;

  // Check if translation is recent (within 24 hours)
  bool get isRecent;
}
```

---

### Mock Translation Responses

**English → Chinese:**
```dart
{
  "success": true,
  "translation": "你好",
  "sourceLanguage": "English",
  "targetLanguage": "中文"
}

// "Hello, world!" → "你好，世界！"
// "How are you?" → "你好吗？"
// "Thank you" → "谢谢"
```

**Chinese → English:**
```dart
{
  "success": true,
  "translation": "Hello",
  "sourceLanguage": "中文",
  "targetLanguage": "English"
}

// "你好" → "Hello"
// "谢谢" → "Thank you"
// "再见" → "Goodbye"
```

**Japanese → English:**
```dart
{
  "success": true,
  "translation": "Hello",
  "sourceLanguage": "日本語",
  "targetLanguage": "English"
}

// "こんにちは" → "Hello"
// "ありがとう" → "Thank you"
// "さようなら" → "Goodbye"
```

---

## Command Mock Data

### Command Task Model

```dart
class CommandTask {
  String id;
  String command;
  TaskStatus status;
  double progress;
  String currentStep;
  String? result;
  DateTime createdAt;
  DateTime? completedAt;
}

enum TaskStatus {
  pending,
  running,
  completed,
  failed,
}
```

---

### Command History Model

```dart
class CommandHistory {
  String id;
  String command;
  String? result;
  TaskStatus status;
  DateTime executedAt;
  Duration? executionTime;

  // Format execution time for display
  String get formattedExecutionTime;

  // Check if command succeeded
  bool get succeeded;
}
```

---

### Mock Command Execution

**Command:** "翻译\"Hello\"到英语"

**Response:**
```dart
{
  "success": true,
  "taskId": "task_123",
  "status": "running",
  "progress": 0.0,
  "currentStep": "Initializing..."
}
```

**Task Update:**
```dart
{
  "taskId": "task_123",
  "status": "completed",
  "progress": 1.0,
  "result": "Translation complete: Hello → Hello",
  "completedAt": "2026-02-08T10:00:05Z"
}
```

---

## Notification Mock Data

### Notification Model

Located at `lib/models/notification.dart`:

```dart
class Notification {
  String id;
  String title;
  String message;
  NotificationType type;
  bool isRead;
  DateTime timestamp;

  // Format timestamp for display
  String get formattedTime;

  // Check if notification is recent (within 1 hour)
  bool get isRecent;
}

enum NotificationType {
  translation,
  quiz,
  chat,
  command,
  system,
}
```

---

### Mock Notifications

```dart
[
  {
    "id": "notif_1",
    "title": "Translation Complete",
    "message": "Your translation is ready",
    "type": "translation",
    "isRead": false,
    "timestamp": "2026-02-08T10:00:00Z"
  },
  {
    "id": "notif_2",
    "title": "Quiz Available",
    "message": "New English quiz is ready",
    "type": "quiz",
    "isRead": false,
    "timestamp": "2026-02-08T09:30:00Z"
  },
  {
    "id": "notif_3",
    "title": "AI Response Ready",
    "message": "Your AI chat response is ready",
    "type": "chat",
    "isRead": true,
    "timestamp": "2026-02-08T09:00:00Z"
  },
  {
    "id": "notif_4",
    "title": "Command Executed",
    "message": "Your command has been completed",
    "type": "command",
    "isRead": true,
    "timestamp": "2026-02-08T08:30:00Z"
  },
  {
    "id": "notif_5",
    "title": "System Update",
    "message": "App has been updated to v1.0.0",
    "type": "system",
    "isRead": false,
    "timestamp": "2026-02-08T08:00:00Z"
  }
]
```

---

## Activity Mock Data

### Activity Card Model

Located at `lib/activity/models/activity_card.dart`:

```dart
class ActivityCard {
  String id;
  String title;
  String description;
  ActivityType type;
  bool isCompleted;
  DateTime? dueDate;

  // Format due date for display
  String get formattedDueDate;

  // Check if activity is overdue
  bool get isOverdue;
}

enum ActivityType {
  quiz,
  translation,
  practice,
  review,
}
```

---

### Todo Item Model

Located at `lib/activity/models/todo_item.dart`:

```dart
class TodoItem {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  // Toggle completion status
  void toggle();

  // Format creation date for display
  String get formattedCreatedAt;
}
```

---

### Mock Activities

```dart
[
  {
    "id": "activity_1",
    "title": "Daily English Quiz",
    "description": "Complete 5 questions",
    "type": "quiz",
    "isCompleted": false,
    "dueDate": "2026-02-08T23:59:59Z"
  },
  {
    "id": "activity_2",
    "title": "Translation Practice",
    "description": "Translate 10 sentences",
    "type": "translation",
    "isCompleted": true,
    "dueDate": "2026-02-08T12:00:00Z"
  },
  {
    "id": "activity_3",
    "title": "Vocabulary Review",
    "description": "Review 20 new words",
    "type": "review",
    "isCompleted": false,
    "dueDate": "2026-02-09T23:59:59Z"
  }
]
```

---

## AI Configuration Mock Data

### AI Config Model

```dart
class AiConfig {
  String model;
  String? apiKey;
  double temperature;
  int maxTokens;
  String systemPrompt;
  bool enhanceTranslation;
  bool smartRecommend;
  bool voiceAssistant;
  bool deepThinkingMode;
}
```

---

### Mock AI Config

```dart
{
  "model": "gpt4",
  "temperature": 0.7,
  "maxTokens": 2048,
  "systemPrompt": "You are a helpful AI assistant.",
  "enhanceTranslation": true,
  "smartRecommend": true,
  "voiceAssistant": true,
  "deepThinkingMode": false
}
```

---

### Supported AI Models

| Model | Key | Use Case |
|-------|-----|----------|
| GPT-4 | `gpt4` | Complex reasoning, enhanced translation |
| GPT-3.5 Turbo | `gpt35` | Fast responses, simple Q&A |
| Claude 3 Opus | `claude` | Long-text analysis, document translation |
| Gemini Pro | `gemini` | Multimodal, image translation |
| Local Model | `local` | Privacy-preserving, offline |
| Custom API | `custom` | Private deployment, third-party |

---

## Error Response Format

All endpoints may return error responses in the following format:

```dart
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

**Common Error Codes:**
- `INVALID_EMAIL`: Invalid email address
- `INVALID_PASSWORD`: Password too short
- `PASSWORD_MISMATCH`: Passwords do not match
- `UNAUTHORIZED`: User not authenticated
- `NOT_FOUND`: Resource not found
- `SERVER_ERROR`: Internal server error

---

## Future Implementation

The mock data will be replaced with actual RESTful API calls when the backend is implemented. The mock data structures will remain compatible with the final API design.

**Planned Endpoints:**
- POST /api/auth/login
- POST /api/auth/register
- GET /api/quiz/questions
- POST /api/quiz/submit
- POST /api/translation/translate
- GET /api/translation/history
- POST /api/commands/execute
- GET /api/notifications
- GET /api/activities
- GET /api/ai/config

---

**Document End**
