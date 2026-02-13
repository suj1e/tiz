/// Profile page data repository
abstract class ProfileRepository {
  /// Get user stats
  Future<UserStats> getUserStats();

  /// Get user achievements
  Future<List<Achievement>> getAchievements();
}

/// User stats data
class UserStats {
  final int daysStreak;
  final int lessonsCompleted;
  final int xpPoints;

  const UserStats({
    required this.daysStreak,
    required this.lessonsCompleted,
    required this.xpPoints,
  });
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool earned;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.earned,
  });
}
