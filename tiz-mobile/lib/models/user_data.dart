/// User Data Models
///
/// This file contains user-related data models for the Tiz app
/// including profile information, learning statistics, and preferences.

import 'package:flutter/material.dart';

/// User model representing a Tiz app user
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final DateTime joinDate;
  final int studyDays;
  final int wordsLearned;
  final int quizzesCompleted;
  final int streak;
  final UserLevel level;
  final List<String> achievements;
  final Map<String, int> languageProgress;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    required this.joinDate,
    this.studyDays = 0,
    this.wordsLearned = 0,
    this.quizzesCompleted = 0,
    this.streak = 0,
    this.level = UserLevel.beginner,
    this.achievements = const [],
    this.languageProgress = const {},
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? bio,
    DateTime? joinDate,
    int? studyDays,
    int? wordsLearned,
    int? quizzesCompleted,
    int? streak,
    UserLevel? level,
    List<String>? achievements,
    Map<String, int>? languageProgress,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      joinDate: joinDate ?? this.joinDate,
      studyDays: studyDays ?? this.studyDays,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      streak: streak ?? this.streak,
      level: level ?? this.level,
      achievements: achievements ?? this.achievements,
      languageProgress: languageProgress ?? this.languageProgress,
    );
  }

  /// Get display name
  String get displayName => name.split(' ')[0];

  /// Get formatted join date
  String get formattedJoinDate {
    return '${joinDate.year}年${joinDate.month}月';
  }

  /// Get total XP points
  int get totalXP {
    return (wordsLearned * 10) +
        (quizzesCompleted * 50) +
        (studyDays * 20) +
        (streak * 5);
  }

  /// Get progress to next level
  double get levelProgress {
    final currentLevelXP = level.requiredXP;
    final nextLevelXP = UserLevel.values
        .firstWhere((l) => l.index > level.index,
            orElse: () => UserLevel.expert)
        .requiredXP;
    final progress = (totalXP - currentLevelXP) / (nextLevelXP - currentLevelXP);
    return progress.clamp(0.0, 1.0);
  }
}

/// User achievement levels
enum UserLevel {
  beginner(0, '初学者', '刚刚开始学习之旅'),
  elementary(100, '初级', '掌握了基础词汇和表达'),
  intermediate(500, '中级', '可以进行日常对话'),
  advanced(1500, '高级', '流利使用多种语言'),
  expert(3000, '专家', '语言大师');

  final int requiredXP;
  final String title;
  final String description;

  const UserLevel(this.requiredXP, this.title, this.description);
}

/// User preference settings
class UserPreferences {
  final ThemeMode themeMode;
  final String defaultLanguage;
  final List<String> favoriteLanguages;
  final bool enableNotifications;
  final bool enableSoundEffects;
  final bool enableVibration;
  final bool autoPlayAudio;
  final double dailyGoalMinutes;
  final bool enableDeepThinking;

  UserPreferences({
    this.themeMode = ThemeMode.system,
    this.defaultLanguage = 'zh',
    this.favoriteLanguages = const ['en', 'ja'],
    this.enableNotifications = true,
    this.enableSoundEffects = true,
    this.enableVibration = true,
    this.autoPlayAudio = false,
    this.dailyGoalMinutes = 30.0,
    this.enableDeepThinking = false,
  });

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? defaultLanguage,
    List<String>? favoriteLanguages,
    bool? enableNotifications,
    bool? enableSoundEffects,
    bool? enableVibration,
    bool? autoPlayAudio,
    double? dailyGoalMinutes,
    bool? enableDeepThinking,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      favoriteLanguages: favoriteLanguages ?? this.favoriteLanguages,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableVibration: enableVibration ?? this.enableVibration,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      enableDeepThinking: enableDeepThinking ?? this.enableDeepThinking,
    );
  }
}

/// User achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final DateTime unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.unlockedAt,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    int? xpReward,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

/// Available achievements
/// Note: Using a function instead of const list because DateTime.now() is not a compile-time constant
List<Achievement> get availableAchievements => [
  Achievement(
    id: 'first_quiz',
    title: '初次测验',
    description: '完成第一个测验',
    icon: '📝',
    xpReward: 50,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'quiz_master',
    title: '测验达人',
    description: '完成10个测验',
    icon: '🏆',
    xpReward: 200,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'word_collector',
    title: '词汇收集者',
    description: '学习100个单词',
    icon: '📚',
    xpReward: 100,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'streak_week',
    title: '坚持一周',
    description: '连续学习7天',
    icon: '🔥',
    xpReward: 150,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'streak_month',
    title: '坚持一月',
    description: '连续学习30天',
    icon: '💪',
    xpReward: 500,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'polyglot',
    title: '多语言学习者',
    description: '同时学习3种语言',
    icon: '🌍',
    xpReward: 300,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'perfect_score',
    title: '完美表现',
    description: '在测验中获得100%分数',
    icon: '⭐',
    xpReward: 100,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'translation_pro',
    title: '翻译专家',
    description: '使用翻译功能50次',
    icon: '🌐',
    xpReward: 150,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'night_owl',
    title: '夜猫子',
    description: '在晚上10点后学习',
    icon: '🦉',
    xpReward: 50,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
  Achievement(
    id: 'early_bird',
    title: '早起鸟',
    description: '在早上6点前学习',
    icon: '🐦',
    xpReward: 50,
    unlockedAt: DateTime.fromMillisecondsSinceEpoch(0),
  ),
];

/// Mock user data for development and testing
class MockUser {
  static User get currentUser => User(
    id: 'user_001',
    name: 'Tiz 用户',
    email: 'user@tiz.app',
    avatar: null,
    bio: '学习语言，探索世界 🌍',
    joinDate: DateTime.now().subtract(const Duration(days: 45)),
    studyDays: 45,
    wordsLearned: 350,
    quizzesCompleted: 12,
    streak: 7,
    level: UserLevel.intermediate,
    achievements: ['first_quiz', 'word_collector', 'streak_week'],
    languageProgress: {
      'en': 65,
      'ja': 40,
      'de': 25,
      'yue': 15,
    },
  );

  static final UserPreferences userPreferences = UserPreferences(
    themeMode: ThemeMode.system,
    defaultLanguage: 'zh',
    favoriteLanguages: ['en', 'ja'],
    enableNotifications: true,
    enableSoundEffects: true,
    enableVibration: true,
    autoPlayAudio: false,
    dailyGoalMinutes: 30.0,
    enableDeepThinking: false,
  );

  static List<Achievement> getUnlockedAchievements() {
    return availableAchievements
        .where((achievement) => currentUser.achievements.contains(achievement.id))
        .map((achievement) => achievement.copyWith(isUnlocked: true))
        .toList();
  }

  static List<Achievement> getLockedAchievements() {
    return availableAchievements
        .where((achievement) => !currentUser.achievements.contains(achievement.id))
        .toList();
  }

  /// Additional mock users for testing
  static List<User> get mockUsers => [
    User(
      id: 'user_001',
      name: 'Tiz 用户',
      email: 'user@tiz.app',
      avatar: null,
      bio: '学习语言，探索世界 🌍',
      joinDate: DateTime.now().subtract(const Duration(days: 45)),
      studyDays: 45,
      wordsLearned: 350,
      quizzesCompleted: 12,
      streak: 7,
      level: UserLevel.intermediate,
      achievements: ['first_quiz', 'word_collector', 'streak_week'],
      languageProgress: {
        'en': 65,
        'ja': 40,
        'de': 25,
        'yue': 15,
      },
    ),
    User(
      id: 'user_002',
      name: 'Alice Chen',
      email: 'alice@example.com',
      avatar: null,
      bio: '热爱学习语言 📚',
      joinDate: DateTime.now().subtract(const Duration(days: 90)),
      studyDays: 90,
      wordsLearned: 800,
      quizzesCompleted: 35,
      streak: 15,
      level: UserLevel.advanced,
      achievements: ['first_quiz', 'quiz_master', 'word_collector', 'streak_week', 'streak_month', 'perfect_score'],
      languageProgress: {
        'en': 85,
        'ja': 70,
        'de': 50,
        'fr': 30,
      },
    ),
    User(
      id: 'user_003',
      name: 'Bob Smith',
      email: 'bob@example.com',
      avatar: null,
      bio: '日语学习中 🇯🇵',
      joinDate: DateTime.now().subtract(const Duration(days: 15)),
      studyDays: 15,
      wordsLearned: 120,
      quizzesCompleted: 5,
      streak: 3,
      level: UserLevel.elementary,
      achievements: ['first_quiz'],
      languageProgress: {
        'ja': 35,
        'en': 20,
      },
    ),
    User(
      id: 'user_004',
      name: 'Carol Wang',
      email: 'carol@example.com',
      avatar: null,
      bio: '多语言爱好者 🌏',
      joinDate: DateTime.now().subtract(const Duration(days: 180)),
      studyDays: 180,
      wordsLearned: 1500,
      quizzesCompleted: 60,
      streak: 30,
      level: UserLevel.expert,
      achievements: ['first_quiz', 'quiz_master', 'word_collector', 'streak_week', 'streak_month', 'polyglot', 'perfect_score', 'translation_pro'],
      languageProgress: {
        'en': 95,
        'ja': 90,
        'de': 80,
        'fr': 75,
        'yue': 60,
        'ko': 45,
      },
    ),
  ];
}

/// Learning session data
class LearningSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionType type;
  final String? language;
  final int durationMinutes;
  final int wordsLearned;
  final int? quizScore;
  final int? quizTotal;

  LearningSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.type,
    this.language,
    this.durationMinutes = 0,
    this.wordsLearned = 0,
    this.quizScore,
    this.quizTotal,
  });

  SessionStatus get status {
    if (endTime == null) return SessionStatus.inProgress;
    return SessionStatus.completed;
  }

  String get durationText {
    if (durationMinutes < 60) {
      return '$durationMinutes分钟';
    }
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '$hours小时${minutes > 0 ? ' $minutes分钟' : ''}';
  }
}

enum SessionType {
  translation,
  quiz,
  conversation,
  vocabulary,
  grammar,
  dialect,
}

enum SessionStatus {
  inProgress,
  completed,
  cancelled,
}

/// Mock learning sessions
List<LearningSession> get mockLearningSessions => [
  LearningSession(
    id: 'session_001',
    startTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    endTime: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    type: SessionType.quiz,
    language: 'en',
    durationMinutes: 15,
    wordsLearned: 5,
    quizScore: 8,
    quizTotal: 10,
  ),
  LearningSession(
    id: 'session_002',
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 45)),
    endTime: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 15)),
    type: SessionType.translation,
    language: 'ja',
    durationMinutes: 30,
    wordsLearned: 12,
  ),
  LearningSession(
    id: 'session_003',
    startTime: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 50)),
    endTime: DateTime.now().subtract(const Duration(days: 2, hours: 5, minutes: 30)),
    type: SessionType.quiz,
    language: 'de',
    durationMinutes: 20,
    wordsLearned: 8,
    quizScore: 9,
    quizTotal: 10,
  ),
];
