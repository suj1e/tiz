import '../repository/profile_repository.dart';

class ProfileMockData {
  ProfileMockData._();

  static const UserStats userStats = UserStats(
    daysStreak: 12,
    lessonsCompleted: 48,
    xpPoints: 850,
  );

  static final List<Achievement> achievements = [
    const Achievement(
      id: 'ach_001',
      title: 'First Steps',
      description: 'Complete your first lesson',
      icon: '🎯',
      earned: true,
    ),
    const Achievement(
      id: 'ach_002',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      icon: '🔥',
      earned: true,
    ),
    const Achievement(
      id: 'ach_003',
      title: 'Quiz Master',
      description: 'Complete 10 quizzes',
      icon: '🏆',
      earned: false,
    ),
    const Achievement(
      id: 'ach_004',
      title: 'Polyglot',
      description: 'Start learning 3 languages',
      icon: '🌍',
      earned: false,
    ),
  ];
}
