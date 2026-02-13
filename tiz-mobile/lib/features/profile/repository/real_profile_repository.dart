import 'package:flutter/foundation.dart';

import 'profile_repository.dart';

class RealProfileRepository implements ProfileRepository {
  @override
  Future<UserStats> getUserStats() async {
    debugPrint('[RealProfileRepository] getUserStats - not implemented');
    return const UserStats(daysStreak: 0, lessonsCompleted: 0, xpPoints: 0);
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    debugPrint('[RealProfileRepository] getAchievements - not implemented');
    return [];
  }
}
