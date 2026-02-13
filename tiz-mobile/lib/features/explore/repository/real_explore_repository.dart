import 'package:flutter/foundation.dart';

import 'explore_repository.dart';

/// Real implementation of ExploreRepository using API
class RealExploreRepository implements ExploreRepository {
  @override
  Future<List<LearningProgress>> getLearningProgress() async {
    debugPrint('[RealExploreRepository] getLearningProgress - not implemented');
    // TODO: Implement API call
    return [];
  }

  @override
  Future<List<QuizItem>> getPopularQuizzes() async {
    debugPrint('[RealExploreRepository] getPopularQuizzes - not implemented');
    // TODO: Implement API call
    return [];
  }

  @override
  Future<List<Language>> getLanguages() async {
    debugPrint('[RealExploreRepository] getLanguages - not implemented');
    // TODO: Implement API call
    return [];
  }
}
