/// Quiz Models Export
/// Re-exports all quiz models for convenience
library;

export 'quiz_status.dart';
export 'quiz_attempt.dart';
export 'quiz_progress.dart';
export 'quiz_filter.dart';
export 'quiz_category.dart';
export 'quiz_difficulty.dart';

// Import for use in this file
import 'quiz_category.dart';
import 'quiz_difficulty.dart';

/// Quiz Mode Enum
enum QuizMode {
  choice,
  conversation,
  voiceCall,
}

/// Quiz Question Model
/// Defines a single quiz question with options, answer, and metadata
class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final QuizDifficulty difficulty;
  final QuizCategory category;

  // New fields for question bank functionality
  final String? tags; // Comma-separated tags (e.g., "grammar,verbs")
  final int? orderIndex; // Display order in list
  final String? hint; // Optional hint for the question
  final DateTime? createdAt; // Question creation date

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.category,
    this.tags,
    this.orderIndex,
    this.hint,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty.name,
      'category': category.name,
      'tags': tags,
      'orderIndex': orderIndex,
      'hint': hint,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  /// Create from map
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List),
      correctAnswer: map['correctAnswer'] as int,
      explanation: map['explanation'] as String,
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuizDifficulty.intermediate,
      ),
      category: QuizCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => QuizCategory.english,
      ),
      tags: map['tags'] as String?,
      orderIndex: map['orderIndex'] as int?,
      hint: map['hint'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
    );
  }

  /// Get option text without letter prefix
  String getOptionText(int index) {
    if (index < 0 || index >= options.length) return '';
    final option = options[index];
    // Remove "A. ", "B. ", etc. prefix if present
    if (option.length > 3 && option[2] == '.') {
      return option.substring(3);
    }
    return option;
  }

  /// Get option letter (A, B, C, D)
  String getOptionLetter(int index) {
    return String.fromCharCode(65 + index); // 65 = 'A'
  }

  /// Get tag list
  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((e) => e.trim()).toList();
  }
}

/// Quiz Session Model
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

  QuizSession({
    required this.id,
    required this.questions,
    required this.mode,
    required this.category,
    required this.startedAt,
    this.currentIndex = 0,
    this.score = 0,
    List<int?>? userAnswers,
    this.isCompleted = false,
  }) : userAnswers = userAnswers ?? List.filled(questions.length, null);

  /// Get current question
  QuizQuestion? get currentQuestion {
    if (currentIndex >= 0 && currentIndex < questions.length) {
      return questions[currentIndex];
    }
    return null;
  }

  /// Get progress (0.0 to 1.0)
  double get progress {
    if (questions.isEmpty) return 0.0;
    return currentIndex / questions.length;
  }

  /// Check if quiz is finished
  bool get isFinished {
    return currentIndex >= questions.length;
  }

  /// Submit answer for current question
  void submitAnswer(int answerIndex) {
    if (currentIndex < userAnswers.length) {
      userAnswers[currentIndex] = answerIndex;
      if (answerIndex == questions[currentIndex].correctAnswer) {
        score++;
      }
    }
  }

  /// Move to next question
  void nextQuestion() {
    if (currentIndex < questions.length) {
      currentIndex++;
    }
  }

  /// Complete quiz
  void complete() {
    isCompleted = true;
  }

  /// Calculate percentage score
  double get percentage {
    if (questions.isEmpty) return 0.0;
    return (score / questions.length) * 100;
  }

  /// Check if user passed (60% or higher)
  bool get passed {
    return percentage >= 60;
  }
}

/// Mock Questions Data
final Map<QuizCategory, List<QuizQuestion>> mockQuestions = {
  QuizCategory.english: [
    QuizQuestion(
      id: 'en_001',
      question: 'What is the past tense of "go"?',
      options: ['A. goed', 'B. went', 'C. gone', 'D. goes'],
      correctAnswer: 1,
      explanation: '"Went" is the irregular past tense of "go".',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.english,
      tags: 'verbs,grammar,tenses',
      orderIndex: 1,
      hint: 'This is an irregular verb',
    ),
    QuizQuestion(
      id: 'en_002',
      question: 'Which article is used before "university"?',
      options: ['A. a', 'B. an', 'C. the', 'D. no article'],
      correctAnswer: 0,
      explanation:
          'We use "a" before "university" because it starts with a consonant sound (/j/).',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.english,
      tags: 'articles,pronunciation',
      orderIndex: 2,
      hint: 'Pay attention to the sound, not just the spelling',
    ),
    QuizQuestion(
      id: 'en_003',
      question: 'Choose the correct spelling:',
      options: ['A. neccessary', 'B. necessary', 'C. necesary', 'D. neccesary'],
      correctAnswer: 1,
      explanation: '"Necessary" is spelled with one "c" and two "s"s.',
      difficulty: QuizDifficulty.intermediate,
      category: QuizCategory.english,
      tags: 'spelling,vocabulary',
      orderIndex: 3,
    ),
    QuizQuestion(
      id: 'en_004',
      question: 'What is the opposite of "expand"?',
      options: ['A. extend', 'B. increase', 'C. contract', 'D. develop'],
      correctAnswer: 2,
      explanation:
          '"Contract" means to decrease in size, scope, or range - the opposite of expand.',
      difficulty: QuizDifficulty.intermediate,
      category: QuizCategory.english,
      tags: 'vocabulary,antonyms',
      orderIndex: 4,
    ),
    QuizQuestion(
      id: 'en_005',
      question: 'Which tense is "I have been working"?',
      options: [
        'A. Present perfect',
        'B. Present continuous',
        'C. Past perfect',
        'D. Present perfect continuous'
      ],
      correctAnswer: 3,
      explanation:
          '"I have been working" is in the present perfect continuous tense, showing an action that started in the past and continues now.',
      difficulty: QuizDifficulty.intermediate,
      category: QuizCategory.english,
      tags: 'grammar,tenses',
      orderIndex: 5,
    ),
  ],
  QuizCategory.japanese: [
    QuizQuestion(
      id: 'jp_001',
      question: '"こんにちは" means?',
      options: ['A. Good morning', 'B. Hello', 'C. Goodbye', 'D. Thank you'],
      correctAnswer: 1,
      explanation: '"Konnichiwa" is the standard daytime greeting meaning "hello".',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.japanese,
      tags: 'greetings,basic',
      orderIndex: 1,
    ),
    QuizQuestion(
      id: 'jp_002',
      question: '"ありがとう" means?',
      options: ['A. Hello', 'B. Sorry', 'C. Thank you', 'D. Goodbye'],
      correctAnswer: 2,
      explanation:
          '"Arigatou" (or "Arigatou gozaimasu" politely) means "thank you".',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.japanese,
      tags: 'greetings,basic',
      orderIndex: 2,
    ),
    QuizQuestion(
      id: 'jp_003',
      question: 'How to say "one" in Japanese?',
      options: ['A. 一 (ichi)', 'B. 二 (ni)', 'C. 三 (san)', 'D. 四 (yon)'],
      correctAnswer: 0,
      explanation: '"一" (ichi) means "one" in Japanese.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.japanese,
      tags: 'numbers',
      orderIndex: 3,
    ),
    QuizQuestion(
      id: 'jp_004',
      question: '"さようなら" means?',
      options: ['A. Hello', 'B. Goodbye', 'C. Thank you', 'D. Sorry'],
      correctAnswer: 1,
      explanation: '"Sayounara" is a formal way to say "goodbye".',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.japanese,
      tags: 'greetings',
      orderIndex: 4,
    ),
    QuizQuestion(
      id: 'jp_005',
      question: '"はい" means?',
      options: ['A. No', 'B. Yes', 'C. Maybe', 'D. Please'],
      correctAnswer: 1,
      explanation: '"Hai" means "yes" in Japanese.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.japanese,
      tags: 'basic',
      orderIndex: 5,
    ),
  ],
  QuizCategory.german: [
    QuizQuestion(
      id: 'de_001',
      question: '"Guten Tag" means?',
      options: ['A. Goodbye', 'B. Good day', 'C. Good night', 'D. Thank you'],
      correctAnswer: 1,
      explanation:
          '"Guten Tag" is a formal daytime greeting meaning "good day" or "hello".',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.german,
      tags: 'greetings',
      orderIndex: 1,
    ),
    QuizQuestion(
      id: 'de_002',
      question: '"Danke" means?',
      options: ['A. Hello', 'B. Please', 'C. Thank you', 'D. Yes'],
      correctAnswer: 2,
      explanation: '"Danke" means "thank you" in German.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.german,
      tags: 'basic',
      orderIndex: 2,
    ),
    QuizQuestion(
      id: 'de_003',
      question: '"Bitte" means?',
      options: ['A. Goodbye', 'B. Please/You\'re welcome', 'C. No', 'D. Yes'],
      correctAnswer: 1,
      explanation:
          '"Bitte" can mean both "please" and "you\'re welcome" depending on the context.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.german,
      tags: 'basic,phrases',
      orderIndex: 3,
    ),
    QuizQuestion(
      id: 'de_004',
      question: 'Numbers: "eins" is?',
      options: ['A. one', 'B. two', 'C. three', 'D. four'],
      correctAnswer: 0,
      explanation: '"Eins" means "one" in German.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.german,
      tags: 'numbers',
      orderIndex: 4,
    ),
    QuizQuestion(
      id: 'de_005',
      question: '"Auf Wiedersehen" means?',
      options: ['A. Hello', 'B. Goodbye', 'C. Please', 'D. Thank you'],
      correctAnswer: 1,
      explanation: '"Auf Wiedersehen" is the formal way to say "goodbye" in German.',
      difficulty: QuizDifficulty.beginner,
      category: QuizCategory.german,
      tags: 'greetings',
      orderIndex: 5,
    ),
  ],
};
