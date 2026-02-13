import '../repository/explore_repository.dart';

class ExploreMockData {
  ExploreMockData._();

  static final List<LearningProgress> learningProgress = [
    const LearningProgress(
      language: 'Spanish',
      level: 'Intermediate',
      progress: 0.65,
      lessonsLeft: 12,
    ),
    const LearningProgress(
      language: 'French',
      level: 'Beginner',
      progress: 0.30,
      lessonsLeft: 28,
    ),
    const LearningProgress(
      language: 'German',
      level: 'Advanced',
      progress: 0.85,
      lessonsLeft: 5,
    ),
  ];

  static final List<QuizItem> popularQuizzes = [
    const QuizItem(
      id: 'quiz_001',
      title: 'Spanish Vocabulary',
      questions: 20,
      difficulty: 'Easy',
      color: 'orange',
    ),
    const QuizItem(
      id: 'quiz_002',
      title: 'French Grammar',
      questions: 15,
      difficulty: 'Medium',
      color: 'blue',
    ),
    const QuizItem(
      id: 'quiz_003',
      title: 'German Basics',
      questions: 25,
      difficulty: 'Hard',
      color: 'red',
    ),
    const QuizItem(
      id: 'quiz_004',
      title: 'Italian Phrases',
      questions: 18,
      difficulty: 'Easy',
      color: 'green',
    ),
  ];

  static final List<Language> languages = [
    const Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
    const Language(code: 'fr', name: 'French', flag: '🇫🇷'),
    const Language(code: 'de', name: 'German', flag: '🇩🇪'),
    const Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
    const Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
    const Language(code: 'ja', name: 'Japanese', flag: '🇯🇵'),
    const Language(code: 'ko', name: 'Korean', flag: '🇰🇷'),
    const Language(code: 'zh', name: 'Chinese', flag: '🇨🇳'),
  ];
}
