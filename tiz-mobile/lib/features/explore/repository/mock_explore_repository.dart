import 'package:flutter/foundation.dart';

import '../mock_data/explore_mock_data.dart';
import 'explore_repository.dart';

/// Mock implementation of ExploreRepository for development
class MockExploreRepository implements ExploreRepository {
  @override
  Future<List<LearningProgress>> getLearningProgress() async {
    debugPrint('[MockExploreRepository] getLearningProgress');
    return ExploreMockData.learningProgress;
  }

  @override
  Future<List<QuizItem>> getPopularQuizzes() async {
    debugPrint('[MockExploreRepository] getPopularQuizzes');
    return ExploreMockData.popularQuizzes;
  }

  @override
  Future<List<Language>> getLanguages() async {
    debugPrint('[MockExploreRepository] getLanguages');
    return ExploreMockData.languages;
  }
}
