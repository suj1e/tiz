/// Minimalist App Constants
/// Following Tiz minimalist design principles
class AppConstants {
  // App Info
  static const String appName = 'Tiz';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyTheme = 'tiz_theme';
  static const String keyAiConfig = 'ai_config';
  static const String keyApiKey = 'api_key';

  // API Endpoints (examples - configure as needed)
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';

  // Animation Durations - Fast 0.15-0.2s
  static const int animationDurationShort = 150;
  static const int animationDurationMedium = 200;

  // Spacing - 4px grid
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;

  // Border Radius - Minimalist 10-12px
  static const double radiusS = 8.0;
  static const double radiusM = 10.0;
  static const double radiusL = 12.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;

  // AI Settings
  static const double defaultTemperature = 0.7;
  static const int defaultMaxTokens = 2048;
  static const int defaultChatHistoryLimit = 50;
}

/// App Strings - All UI text
class AppStrings {
  // Navigation - 4 tabs: Bot, Explore, Inbox, Profile
  static const String navBot = 'Bot';
  static const String navExplore = 'Explore';
  static const String navInbox = 'Inbox';
  static const String navProfile = 'Profile';

  // Explore - Tab based
  static const String exploreTitle = '发现';
  static const String exploreSubtitle = '语言 · 测验';
  static const String tabLanguage = '语言';
  static const String tabQuiz = '测验';
  static const String tabBot = 'Bot';

  // Language Learning
  static const String languageLearning = '语言学习';
  static const String translation = '翻译';
  static const String aiEnhancedTranslation = 'AI增强翻译';
  static const String aiDeepTranslation = 'AI深度翻译';
  static const String aiAssistant = 'Bot';
  static const String cantoneseLearningAssistant = '粤语学习助手';
  static const String sichuaneseLearningAssistant = '川普学习助手';
  static const String selectLanguage = '选择语言';
  static const String learningProgress = '学习进度';
  static const String masteredPhrases = '已掌握';
  static const String phrasesUnit = '个短语';
  static const String todayLearning = '今日学习';
  static const String learningTime = '学习时长';
  static const String learningStreak = '连续学习';
  static const String minutesUnit = ' 分钟';
  static const String daysUnit = ' 天';

  // Commands
  static const String commandsHint = '输入指令...';
  static const String commandsExecuting = '执行中';
  static const String commandStartQuiz = '开始英语测验';
  static const String commandTranslate = '翻译"你好"到英语';
  static const String commandPlan = '制定学习计划';

  // Translation
  static const String translateTitle = '翻译';
  static const String translateHint = '输入要翻译的文本...';
  static const String translateButton = '翻译';

  // Quiz
  static const String quizTitle = '知识测验';
  static const String quizStart = '开始测验';
  static const String quizModeChoice = '选择题';
  static const String quizModeConversation = '对话';
  static const String quizModeVoiceCall = '通话';
  static const String quizCategoryEnglish = '英语';
  static const String quizCategoryJapanese = '日语';
  static const String quizCategoryGerman = '德语';

  // Chat
  static const String chatTitle = 'AI 对话';
  static const String chatHint = '输入问题...';
  static const String chatSend = '发送';

  // Profile
  static const String profileTitle = 'Profile';
  static const String profileSettings = '设置';
  static const String profileTheme = '主题';
  static const String profileAiSettings = 'AI 设置';

  // AI Features
  static const String aiModel = 'AI 模型';
  static const String aiEnhanceTranslate = 'AI 增强翻译';
  static const String aiSmartRecommend = '智能推荐';
  static const String aiVoiceAssistant = '语音助手';
  static const String aiDeepThinking = '深度思考模式';

  // Theme
  static const String themeLight = '浅色';
  static const String themeDark = '深色';

  // Notifications
  static const String notificationTitle = '通知';
  static const String notificationEmpty = '暂无通知';
  static const String markAllRead = '全部已读';

  // Inbox
  static const String inboxTitle = 'Inbox';
  static const String inboxEmpty = '暂无消息';
  static const String inboxMarkAllRead = '全部标为已读';

  // Actions
  static const String send = '发送';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String save = '保存';
}

/// App Routes
class AppRoutes {
  static const String home = '/';
  static const String explore = '/explore';
  static const String profile = '/profile';
}
