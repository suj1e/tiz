/// Chat Mock Data
///
/// This file contains mock response data for the AI chat assistant
/// for testing and development purposes.

import 'package:flutter/material.dart';

/// Chat message types
enum ChatMessageType {
  user,
  assistant,
  system,
}

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isTyping,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

/// Chat response pattern for keyword matching
class ChatResponse {
  final List<String> keywords;
  final String response;
  final List<String>? quickActions;
  final bool requiresFollowUp;

  ChatResponse({
    required this.keywords,
    required this.response,
    this.quickActions,
    this.requiresFollowUp = false,
  });
}

/// Mock response patterns for the AI assistant
final List<ChatResponse> mockResponsePatterns = [
  // Greetings
  ChatResponse(
    keywords: ['你好', 'hello', 'hi', '嗨', '您好'],
    response: '你好！我是 Tiz Bot。我可以帮助你翻译文本、学习语言、参加测验，或者回答你的问题。今天我能帮你什么？',
    quickActions: ['翻译文本', '开始测验', '学习语言'],
  ),
  ChatResponse(
    keywords: ['早上好', 'good morning', '早啊'],
    response: '早上好！美好的一天开始了，想学习点什么新内容吗？',
    quickActions: ['每日测验', '翻译单词'],
  ),
  ChatResponse(
    keywords: ['晚上好', 'good evening'],
    response: '晚上好！今天过得怎么样？晚上可以放松一下，学点有趣的知识。',
  ),
  ChatResponse(
    keywords: ['晚安', 'good night', '睡了'],
    response: '晚安！祝你做个好梦。明天继续努力学习吧！💪',
  ),

  // Translation
  ChatResponse(
    keywords: ['翻译', 'translate', '译文'],
    response: '我可以帮你翻译文本！请到"发现"页面的"翻译"标签，输入你想翻译的文本，选择源语言和目标语言，我会立即为你翻译。目前支持中文、英语、日语等多种语言互译。',
    quickActions: ['前往翻译', '支持的语言'],
    requiresFollowUp: true,
  ),
  ChatResponse(
    keywords: ['英语怎么说', 'how to say in english'],
    response: '你想知道哪个词或句子的英语表达？告诉我中文，我会帮你翻译成地道的英语。',
  ),
  ChatResponse(
    keywords: ['日语怎么说', 'how to say in japanese'],
    response: '你想了解哪个词或句子的日语说法？告诉我，我会提供准确的日语翻译，包括假名和罗马音。',
  ),
  ChatResponse(
    keywords: ['粤语怎么说', 'how to say in cantonese'],
    response: '粤语是很有趣的方言！告诉我你想学什么，我会教你地道的粤语表达。',
  ),

  // Quiz
  ChatResponse(
    keywords: ['测验', 'quiz', 'test', '考试', '测试'],
    response: '测验是检验学习效果的好方法！你可以：\n\n📝 **选择题模式**：从四个选项中选择正确答案\n💬 **对话模式**：与AI进行问答互动\n📞 **语音通话模式**：通过语音对话进行测验\n\n目前提供英语、日语、德语测验，每种语言有10道题目。到"发现"页面的"测验"标签开始吧！',
    quickActions: ['英语测验', '日语测验', '德语测验'],
  ),
  ChatResponse(
    keywords: ['英语测验', 'english quiz'],
    response: '英语测验准备好了！包含10道题目，涵盖语法、词汇、阅读理解等。难度从初级到高级不等。准备好了吗？',
    quickActions: ['开始测验', '查看题库'],
  ),
  ChatResponse(
    keywords: ['日语测验', 'japanese quiz'],
    response: '日语测验来啦！包含假名、汉字、语法、日常用语等10道题目。适合各个水平的学习者。',
    quickActions: ['开始测验', '学习五十音'],
  ),
  ChatResponse(
    keywords: ['德语测验', 'german quiz'],
    response: '德语测验包含基础词汇、语法、日常对话等10道题目。德语的语法系统很严谨，通过测验可以更好地掌握！',
    quickActions: ['开始测验', '学习格的变化'],
  ),

  // Learning
  ChatResponse(
    keywords: ['学习', 'learn', 'study', '学'],
    response: '学习新语言是一个令人兴奋的旅程！Tiz 提供了多种学习方式：\n\n🔤 **词汇学习**：积累日常用语和核心词汇\n📚 **测验系统**：通过练习巩固知识\n🗣️ **对话练习**：与AI进行语言交流\n🌐 **方言学习**：学习粤语、四川话等方言\n\n你想从哪里开始？',
    quickActions: ['学习计划', '今日词汇', '方言学习'],
  ),
  ChatResponse(
    keywords: ['怎么学', 'how to learn', '学习方法'],
    response: '有效的语言学习建议：\n\n1️⃣ **每天坚持**：每天15-30分钟比周末突击更有效\n2️⃣ **多听多说**：利用语音功能练习口语\n3️⃣ **活学活用**：通过测验检验学习成果\n4️⃣ **积累词汇**：从日常用语开始，逐步扩展\n5️⃣ **定期复习**：使用测验功能巩固已学内容\n\n需要我帮你制定学习计划吗？',
  ),
  ChatResponse(
    keywords: ['词汇', 'vocabulary', '单词', '生词'],
    response: '词汇是语言的基石！建议按以下顺序学习：\n\n📌 **基础词汇**：数字、颜色、时间、家庭成员\n📌 **日常用语**：问候、礼貌用语、常见表达\n📌 **高频词汇**：日常生活中的常用词\n📌 **专业词汇**：根据需要扩展特定领域\n\n通过翻译功能和测验系统，你可以逐步掌握这些词汇！',
    quickActions: ['今日词汇', '词汇测验'],
  ),

  // Dialect learning
  ChatResponse(
    keywords: ['方言', 'dialect', '粤语', '四川话', 'cantonese'],
    response: '方言学习很有趣！Tiz 支持多种方言学习：\n\n🎭 **粤语（广东话）**：香港、澳门、广东地区使用\n🌶️ **四川话**：四川、重庆地区使用，语调独特\n\n每种方言包含：\n- 日常用语\n- 数字和时间的表达\n- 地道俗语\n- 发音提示\n\n方言学习功能即将推出，敬请期待！',
    quickActions: ['粤语入门', '四川话入门'],
  ),

  // Help and support
  ChatResponse(
    keywords: ['帮助', 'help', '怎么用', '如何使用'],
    response: '我很乐意帮助你！Tiz 的主要功能包括：\n\n🌐 **翻译**：支持多语言即时翻译\n📝 **测验**：选择题、对话、语音通话三种模式\n💬 **Bot**：就是我！随时为你答疑解惑\n⚡ **指令**：语音或文字指令快速执行操作\n\n你还可以在"个人资料"页面配置 AI 模型、切换主题等。有什么具体问题吗？',
    quickActions: ['功能介绍', '常见问题'],
  ),
  ChatResponse(
    keywords: ['功能', 'features', '功能介绍'],
    response: 'Tiz 的核心功能：\n\n🏠 **首页**：快速访问常用功能，查看学习进度\n🔍 **发现页面**：\n   • 翻译工具 - 多语言即时翻译\n   • 测验系统 - 三种模式，多语言选择\n   • Bot - 智能问答和学习支持\n   • 指令系统 - 语音/文字指令快速操作\n👤 **个人资料**：用户信息、AI 配置、应用设置\n\n需要了解某个功能的详细用法吗？',
  ),
  ChatResponse(
    keywords: ['问题', 'problem', '错误', 'error', 'bug', '报错'],
    response: '遇到问题了？别担心，我可以帮你解决。请告诉我：\n\n1. 你在尝试做什么操作？\n2. 出现了什么错误信息？\n3. 问题发生在哪个页面？\n\n提供这些信息后，我能更好地帮助你解决问题。',
  ),

  // AI and technology
  ChatResponse(
    keywords: ['ai', '人工智能', '模型', 'model'],
    response: 'Tiz 由强大的 AI 模型驱动！支持的 AI 模型包括：\n\n🤖 **GPT-4**：OpenAI 最先进的模型，擅长复杂推理\n🧠 **Claude**：擅长长文本分析和深度思考\n💎 **Gemini**：Google 的多模态模型\n🔒 **本地模型**：隐私保护，离线可用\n\n在"个人资料 → AI 设置"中可以选择和配置模型。需要配置 API 密钥才能使用在线模型。',
    quickActions: ['配置 AI', '查看模型'],
  ),
  ChatResponse(
    keywords: ['深度思考', 'deep thinking', '思考模式'],
    response: '深度思考模式可以让 AI 进行更深入的分析和推理。当遇到复杂问题时，启用此模式可以获得更详细的解答。\n\n你可以在"个人资料 → AI 设置"中开启或关闭深度思考模式。',
  ),

  // Language specific
  ChatResponse(
    keywords: ['五十音', 'hiragana', 'katakana', '假名'],
    response: '日语五十音图是学习日语的基础！\n\n📝 **平假名（Hiragana）**：用于语法成分和本土词汇\n📝 **片假名（Katakana）**：用于外来词和强调\n📝 **罗马音（Romaji）**：用拉丁字母标注发音\n\n建议按以下顺序学习：\n1. 先学平假名的元音（あいうえお）\n2. 再学辅音与元音的组合\n3. 最后学习片假名\n\n需要五十音图的学习资料吗？',
  ),
  ChatResponse(
    keywords: ['语法', 'grammar', '文法'],
    response: '语法是语言的骨架！不同语言的语法特点：\n\n🇬🇧 **英语**：主谓宾结构，时态系统复杂\n🇯🇵 **日语**：主宾谓结构，助词很重要，动词后置\n🇩🇪 **德语**：四个格，三个性，词尾变化丰富\n\n你想学习哪种语言的语法？我可以为你详细介绍！',
  ),

  // Encouragement
  ChatResponse(
    keywords: ['坚持', 'continue', '加油', '努力'],
    response: '语言学习是一个漫长的过程，但每一步都有意义！💪\n\n✨ 保持耐心：学习需要时间积累\n✨ 庆祝进步：即使是很小的进步也值得鼓励\n✨ 不要害怕犯错：错误是学习的一部分\n✨ 享受过程：发现语言之美，体验文化差异\n\n你已经很棒了，继续加油！',
  ),
  ChatResponse(
    keywords: ['放弃', 'give up', '太难了', '学不会'],
    response: '别灰心！遇到困难是正常的。每个人的学习节奏不同，重要的是不要放弃。\n\n💡 建议：\n• 从简单的内容开始，建立信心\n• 每天学习一点点，保持连续性\n• 使用测验功能检验学习效果\n• 向 Bot 提问，我随时帮助你\n\n我相信你能做到！需要我帮你调整学习计划吗？',
  ),

  // Fun and casual
  ChatResponse(
    keywords: ['笑话', 'joke', '幽默', 'funny'],
    response: '来个语言学习的笑话吧！😄\n\n为什么学英语的人喜欢喝咖啡？\n因为英语有 "present tense"（现在时/咖啡时）！\n\n希望能让你开心一下！学习时保持轻松的心情也很重要哦。',
  ),
  ChatResponse(
    keywords: ['谢谢', 'thank', '感谢'],
    response: '不客气！能帮助到你我很开心。😊\n\n如果还有其他问题，随时来找我。祝你学习愉快！',
  ),

  // Fallback responses
  ChatResponse(
    keywords: [],
    response: '我明白了。作为一个 AI 学习 Bot，我可以帮助你：\n\n• 翻译各种语言的文本\n• 解答语言学习问题\n• 提供学习建议和方法\n• 进行语言测验\n\n请告诉我更多细节，我会尽力帮助你！',
  ),
];

/// Get AI response based on user input
ChatMessage getAIResponse(String userInput) {
  final normalizedInput = userInput.toLowerCase();

  // Try to find matching response pattern
  for (var pattern in mockResponsePatterns) {
    if (pattern.keywords.isEmpty) continue; // Skip fallback

    for (var keyword in pattern.keywords) {
      if (normalizedInput.contains(keyword.toLowerCase())) {
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: pattern.response,
          type: ChatMessageType.assistant,
          timestamp: DateTime.now(),
        );
      }
    }
  }

  // Return fallback response
  final fallbackPattern = mockResponsePatterns.last;
  return ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    content: fallbackPattern.response,
    type: ChatMessageType.assistant,
    timestamp: DateTime.now(),
  );
}

/// Get quick action suggestions based on user input
List<String> getQuickActions(String userInput) {
  final normalizedInput = userInput.toLowerCase();

  for (var pattern in mockResponsePatterns) {
    if (pattern.keywords.isEmpty) continue;

    for (var keyword in pattern.keywords) {
      if (normalizedInput.contains(keyword.toLowerCase())) {
        return pattern.quickActions ?? [];
      }
    }
  }

  return [];
}

/// Mock conversation history for demo
final List<ChatMessage> mockConversationHistory = [
  ChatMessage(
    id: '1',
    content: '你好！我想学习日语',
    type: ChatMessageType.user,
    timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 30)),
  ),
  ChatMessage(
    id: '2',
    content: '你好！日语是一门很有趣的语言。你想从哪里开始？我可以帮你：\n\n• 学习五十音图（平假名和片假名）\n• 学习基础词汇和问候语\n• 进行日语测验\n\n你想先了解哪个？',
    type: ChatMessageType.assistant,
    timestamp: DateTime.now().subtract(Duration(hours: 2, minutes: 29)),
  ),
  ChatMessage(
    id: '3',
    content: '我想学习五十音图',
    type: ChatMessageType.user,
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 35)),
  ),
  ChatMessage(
    id: '4',
    content: '好的！日语五十音图是学习日语的基础。五十音图包括：\n\n📝 **平假名（Hiragana）**：46个基础字符\n📝 **片假名（Katakana）**：46个基础字符\n\n建议从平假名的元音开始：あいうえお\n然后是かきくけこ、さしすせそ...\n\n我可以提供五十音图的学习资料，你想先看平假名还是片假名？',
    type: ChatMessageType.assistant,
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 36)),
  ),
  ChatMessage(
    id: '5',
    content: '平假名，谢谢',
    type: ChatMessageType.user,
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
  ),
  ChatMessage(
    id: '6',
    content: '不客气！这是平假元音：\n\nあ  - a\nい  - i\nう  - u\nえ  - e\nお  - o\n\n接下来是か行：\nか (ka) き (ki) く (ku) け (ke) こ (ko)\n\n建议每天学习2-3行，通过书写和朗读来记忆。需要我继续提供完整的五十音图吗？',
    type: ChatMessageType.assistant,
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 41)),
  ),
];

/// Welcome message when chat is first opened
ChatMessage welcomeMessage = ChatMessage(
  id: 'welcome',
  content: '👋 你好！我是 Tiz Bot，很高兴见到你！\n\n我可以帮助你：\n\n🌐 **翻译文本**：支持多种语言互译\n📝 **语言测验**：英语、日语、德语\n💡 **学习建议**：词汇、语法、学习方法\n🗣️ **口语练习**：通过对话提升语言能力\n\n有什么我可以帮助你的吗？',
  type: ChatMessageType.assistant,
  timestamp: DateTime.now(),
);

/// Typing indicator message
ChatMessage typingIndicator = ChatMessage(
  id: 'typing',
  content: '正在思考...',
  type: ChatMessageType.assistant,
  timestamp: DateTime.now(),
  isTyping: true,
);
