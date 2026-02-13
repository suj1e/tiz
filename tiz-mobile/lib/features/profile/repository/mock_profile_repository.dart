import 'package:flutter/foundation.dart';

import '../mock_data/profile_mock_data.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserStats> getUserStats() async {
    debugPrint('[MockProfileRepository] getUserStats');
    return ProfileMockData.userStats;
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    debugPrint('[MockProfileRepository] getAchievements');
    return ProfileMockData.achievements;
  }
}
