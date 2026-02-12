/// Translation Mock Data
///
/// This file contains comprehensive translation data for common phrases
/// across multiple languages for testing and development purposes.

/// Translation database with Chinese as the source language
/// Maps Chinese phrases to their translations in various languages
const Map<String, Map<String, String>> translationDatabase = {
  // Greetings
  "你好": {"en": "Hello", "ja": "こんにちは", "yue": "你好", "sc": "你好"},
  "早上好": {"en": "Good morning", "ja": "おはよう", "yue": "早晨", "sc": "早上好"},
  "下午好": {"en": "Good afternoon", "ja": "こんにちは", "yue": "午安", "sc": "下午好"},
  "晚上好": {"en": "Good evening", "ja": "こんばんは", "yue": "晚上好", "sc": "晚上好"},
  "晚安": {"en": "Good night", "ja": "おやすみ", "yue": "早唞", "sc": "晚安"},
  "再见": {"en": "Goodbye", "ja": "さようなら", "yue": "拜拜", "sc": "再见"},
  "拜拜": {"en": "Bye bye", "ja": "バイバイ", "yue": "拜拜", "sc": "拜拜"},
  "好久不见": {"en": "Long time no see", "ja": "お久しぶりです", "yue": "好久唔见", "sc": "好久不见"},

  // Polite expressions
  "谢谢": {"en": "Thank you", "ja": "ありがとう", "yue": "唔该", "sc": "谢谢"},
  "非常感谢": {"en": "Thank you very much", "ja": "どうもありがとう", "yue": "多谢唔该", "sc": "非常感谢"},
  "不客气": {"en": "You're welcome", "ja": "どういたしまして", "yue": "唔使客气", "sc": "不客气"},
  "对不起": {"en": "Sorry", "ja": "すみません", "yue": "对唔住", "sc": "对不起"},
  "没关系": {"en": "It's okay", "ja": "大丈夫です", "yue": "无相干", "sc": "没关系"},
  "请": {"en": "Please", "ja": "お願いします", "yue": "唔该", "sc": "请"},
  "不好意思": {"en": "Excuse me", "ja": "すみません", "yue": "唔好意思", "sc": "不好意思"},

  // Common questions
  "你好吗": {"en": "How are you?", "ja": "お元気ですか", "yue": "你好吗", "sc": "你好吗"},
  "你叫什么名字": {"en": "What's your name?", "ja": "お名前は何ですか", "yue": "你叫咩名", "sc": "你叫什么名字"},
  "你来自哪里": {"en": "Where are you from?", "ja": "どこから来ましたか", "yue": "你来自边度", "sc": "你来自哪里"},
  "你会说中文吗": {"en": "Do you speak Chinese?", "ja": "中国語を話せますか", "yue": "你识唔识讲中文", "sc": "你会说中文吗"},
  "你明白吗": {"en": "Do you understand?", "ja": "分かりますか", "yue": "你明唔明", "sc": "你明白吗"},
  "现在几点": {"en": "What time is it?", "ja": "何時ですか", "yue": "而家几点", "sc": "现在几点"},
  "今天星期几": {"en": "What day is today?", "ja": "今日は何曜日ですか", "yue": "今日星期几", "sc": "今天星期几"},
  "今天几号": {"en": "What's the date today?", "ja": "今日は何日ですか", "yue": "今日几号", "sc": "今天几号"},

  // Basic responses
  "是": {"en": "Yes", "ja": "はい", "yue": "系", "sc": "是"},
  "不是": {"en": "No", "ja": "いいえ", "yue": "唔系", "sc": "不是"},
  "可能": {"en": "Maybe", "ja": "多分", "yue": "可能", "sc": "可能"},
  "我不知道": {"en": "I don't know", "ja": "知りません", "yue": "我唔知", "sc": "我不知道"},
  "我明白了": {"en": "I understand", "ja": "分かりました", "yue": "我明喇", "sc": "我明白了"},
  "我不会": {"en": "I can't", "ja": "できません", "yue": "我唔识", "sc": "我不会"},
  "我会": {"en": "I can", "ja": "できます", "yue": "我会", "sc": "我会"},

  // Numbers
  "一": {"en": "One", "ja": "一", "yue": "一", "sc": "一"},
  "二": {"en": "Two", "ja": "二", "yue": "二", "sc": "二"},
  "三": {"en": "Three", "ja": "三", "yue": "三", "sc": "三"},
  "四": {"en": "Four", "ja": "四", "yue": "四", "sc": "四"},
  "五": {"en": "Five", "ja": "五", "yue": "五", "sc": "五"},
  "六": {"en": "Six", "ja": "六", "yue": "六", "sc": "六"},
  "七": {"en": "Seven", "ja": "七", "yue": "七", "sc": "七"},
  "八": {"en": "Eight", "ja": "八", "yue": "八", "sc": "八"},
  "九": {"en": "Nine", "ja": "九", "yue": "九", "sc": "九"},
  "十": {"en": "Ten", "ja": "十", "yue": "十", "sc": "十"},
  "一百": {"en": "One hundred", "ja": "百", "yue": "一百", "sc": "一百"},
  "一千": {"en": "One thousand", "ja": "千", "yue": "一千", "sc": "一千"},
  "一万": {"en": "Ten thousand", "ja": "一万", "yue": "一万", "sc": "一万"},

  // Time and dates
  "今天": {"en": "Today", "ja": "今日", "yue": "今日", "sc": "今天"},
  "明天": {"en": "Tomorrow", "ja": "明日", "yue": "听日", "sc": "明天"},
  "昨天": {"en": "Yesterday", "ja": "昨日", "yue": "琴日", "sc": "昨天"},
  "现在": {"en": "Now", "ja": "今", "yue": "而家", "sc": "现在"},
  "以后": {"en": "Later", "ja": "後で", "yue": "之后", "sc": "以后"},
  "以前": {"en": "Before", "ja": "前に", "yue": "之前", "sc": "以前"},
  "早上": {"en": "Morning", "ja": "朝", "yue": "朝早", "sc": "早上"},
  "中午": {"en": "Noon", "ja": "昼", "yue": "中午", "sc": "中午"},
  "下午": {"en": "Afternoon", "ja": "午後", "yue": "下午", "sc": "下午"},
  "晚上": {"en": "Evening", "ja": "夜", "yue": "晚上", "sc": "晚上"},
  "星期一": {"en": "Monday", "ja": "月曜日", "yue": "星期一", "sc": "星期一"},
  "星期二": {"en": "Tuesday", "ja": "火曜日", "yue": "星期二", "sc": "星期二"},
  "星期三": {"en": "Wednesday", "ja": "水曜日", "yue": "星期三", "sc": "星期三"},
  "星期四": {"en": "Thursday", "ja": "木曜日", "yue": "星期四", "sc": "星期四"},
  "星期五": {"en": "Friday", "ja": "金曜日", "yue": "星期五", "sc": "星期五"},
  "星期六": {"en": "Saturday", "ja": "土曜日", "yue": "星期六", "sc": "星期六"},
  "星期日": {"en": "Sunday", "ja": "日曜日", "yue": "星期日", "sc": "星期日"},

  // Common phrases
  "我爱你": {"en": "I love you", "ja": "愛してる", "yue": "我愛你", "sc": "我爱你"},
  "我也爱你": {"en": "I love you too", "ja": "私も愛してる", "yue": "我愛你啦", "sc": "我也爱你"},
  "祝你生日快乐": {"en": "Happy birthday", "ja": "お誕生日おめでとう", "yue": "生日快樂", "sc": "祝你生日快乐"},
  "恭喜": {"en": "Congratulations", "ja": "おめでとう", "yue": "恭喜", "sc": "恭喜"},
  "新年快乐": {"en": "Happy New Year", "ja": "明けましておめでとう", "yue": "新年快樂", "sc": "新年快乐"},
  "圣诞快乐": {"en": "Merry Christmas", "ja": "メリークリスマス", "yue": "聖誕快樂", "sc": "圣诞快乐"},

  // Food and drink
  "我饿了": {"en": "I'm hungry", "ja": "お腹が空きました", "yue": "我肚餓", "sc": "我饿了"},
  "我渴了": {"en": "I'm thirsty", "ja": "喉が渇きました", "yue": "我口渴", "sc": "我渴了"},
  "好吃": {"en": "Delicious", "ja": "美味しい", "yue": "好食", "sc": "好吃"},
  "难吃": {"en": "Tastes bad", "ja": "不味い", "yue": "难食", "sc": "难吃"},
  "吃饭": {"en": "Eat", "ja": "食べる", "yue": "食飯", "sc": "吃饭"},
  "喝水": {"en": "Drink water", "ja": "水を飲む", "yue": "飲水", "sc": "喝水"},
  "茶": {"en": "Tea", "ja": "お茶", "yue": "茶", "sc": "茶"},
  "咖啡": {"en": "Coffee", "ja": "コーヒー", "yue": "咖啡", "sc": "咖啡"},

  // Places and locations
  "家": {"en": "Home", "ja": "家", "yue": "屋企", "sc": "家"},
  "学校": {"en": "School", "ja": "学校", "yue": "學校", "sc": "学校"},
  "公司": {"en": "Company/Office", "ja": "会社", "yue": "公司", "sc": "公司"},
  "医院": {"en": "Hospital", "ja": "病院", "yue": "醫院", "sc": "医院"},
  "商店": {"en": "Shop", "ja": "店", "yue": "商舖", "sc": "商店"},
  "餐厅": {"en": "Restaurant", "ja": "レストラン", "yue": "餐廳", "sc": "餐厅"},
  "厕所": {"en": "Toilet", "ja": "トイレ", "yue": "廁所", "sc": "厕所"},
  "在哪里": {"en": "Where is it?", "ja": "どこですか", "yue": "喺邊度", "sc": "在哪里"},

  // Transportation
  "出租车": {"en": "Taxi", "ja": "タクシー", "yue": "的士", "sc": "出租车"},
  "公共汽车": {"en": "Bus", "ja": "バス", "yue": "巴士", "sc": "公共汽车"},
  "地铁": {"en": "Subway", "ja": "地下鉄", "yue": "地鐵", "sc": "地铁"},
  "火车": {"en": "Train", "ja": "電車", "yue": "火車", "sc": "火车"},
  "飞机": {"en": "Airplane", "ja": "飛行機", "yue": "飛機", "sc": "飞机"},
  "船": {"en": "Boat", "ja": "船", "yue": "船", "sc": "船"},

  // Weather
  "晴天": {"en": "Sunny", "ja": "晴れ", "yue": "晴天", "sc": "晴天"},
  "阴天": {"en": "Cloudy", "ja": "曇り", "yue": "陰天", "sc": "阴天"},
  "下雨": {"en": "Rainy", "ja": "雨", "yue": "落雨", "sc": "下雨"},
  "下雪": {"en": "Snowy", "ja": "雪", "yue": "落雪", "sc": "下雪"},
  "有风": {"en": "Windy", "ja": "風", "yue": "有風", "sc": "有风"},
  "热": {"en": "Hot", "ja": "暑い", "yue": "熱", "sc": "热"},
  "冷": {"en": "Cold", "ja": "寒い", "yue": "凍", "sc": "冷"},

  // Colors
  "红色": {"en": "Red", "ja": "赤", "yue": "紅色", "sc": "红色"},
  "蓝色": {"en": "Blue", "ja": "青", "yue": "藍色", "sc": "蓝色"},
  "绿色": {"en": "Green", "ja": "緑", "yue": "綠色", "sc": "绿色"},
  "黄色": {"en": "Yellow", "ja": "黄色", "yue": "黃色", "sc": "黄色"},
  "白色": {"en": "White", "ja": "白", "yue": "白色", "sc": "白色"},
  "黑色": {"en": "Black", "ja": "黒", "yue": "黑色", "sc": "黑色"},

  // Common verbs
  "来": {"en": "Come", "ja": "来る", "yue": "嚟", "sc": "来"},
  "去": {"en": "Go", "ja": "行く", "yue": "去", "sc": "去"},
  "看": {"en": "Look/See", "ja": "見る", "yue": "睇", "sc": "看"},
  "听": {"en": "Listen", "ja": "聞く", "yue": "聽", "sc": "听"},
  "说": {"en": "Speak/Talk", "ja": "話す", "yue": "講", "sc": "说"},
  "读": {"en": "Read", "ja": "読む", "yue": "讀", "sc": "读"},
  "写": {"en": "Write", "ja": "書く", "yue": "寫", "sc": "写"},
  "学习": {"en": "Study/Learn", "ja": "勉強する", "yue": "學習", "sc": "学习"},
  "工作": {"en": "Work", "ja": "働く", "yue": "工作", "sc": "工作"},
  "休息": {"en": "Rest", "ja": "休む", "yue": "休息", "sc": "休息"},
  "睡觉": {"en": "Sleep", "ja": "寝る", "yue": "瞓覺", "sc": "睡觉"},
  "起床": {"en": "Wake up", "ja": "起きる", "yue": "起身", "sc": "起床"},

  // Family
  "父亲": {"en": "Father", "ja": "父", "yue": "老窦", "sc": "父亲"},
  "母亲": {"en": "Mother", "ja": "母", "yue": "老母", "sc": "母亲"},
  "哥哥": {"en": "Older brother", "ja": "兄", "yue": "阿哥", "sc": "哥哥"},
  "姐姐": {"en": "Older sister", "ja": "姉", "yue": "家姐", "sc": "姐姐"},
  "弟弟": {"en": "Younger brother", "ja": "弟", "yue": "細佬", "sc": "弟弟"},
  "妹妹": {"en": "Younger sister", "ja": "妹", "yue": "細妹", "sc": "妹妹"},
  "儿子": {"en": "Son", "ja": "息子", "yue": "仔", "sc": "儿子"},
  "女儿": {"en": "Daughter", "ja": "娘", "yue": "女", "sc": "女儿"},

  // Questions words
  "什么": {"en": "What", "ja": "何", "yue": "乜嘢", "sc": "什么"},
  "哪里": {"en": "Where", "ja": "どこ", "yue": "邊度", "sc": "哪里"},
  "什么时候": {"en": "When", "ja": "いつ", "yue": "幾時", "sc": "什么时候"},
  "为什么": {"en": "Why", "ja": "なぜ", "yue": "點解", "sc": "为什么"},
  "怎么": {"en": "How", "ja": "どう", "yue": "點樣", "sc": "怎么"},
  "多少": {"en": "How much/many", "ja": "いくつ", "yue": "幾多", "sc": "多少"},
  "哪个": {"en": "Which", "ja": "どれ", "yue": "邊個", "sc": "哪个"},
  "谁": {"en": "Who", "ja": "誰", "yue": "邊個", "sc": "谁"},
};

/// Language codes supported by the translation system
enum TranslationLanguage {
  chinese('zh', '中文'),
  english('en', 'English'),
  japanese('ja', '日本語'),
  cantonese('yue', '粵語'),
  simplifiedChinese('sc', '简体中文');

  final String code;
  final String name;

  const TranslationLanguage(this.code, this.name);
}

/// Get translation for a text from source to target language
///
/// Parameters:
/// - text: The text to translate
/// - sourceLanguage: The source language code
/// - targetLanguage: The target language code
///
/// Returns the translated text, or null if translation not found
String? getTranslation(
  String text,
  TranslationLanguage sourceLanguage,
  TranslationLanguage targetLanguage,
) {
  // Handle Chinese to other languages
  if (sourceLanguage == TranslationLanguage.chinese ||
      sourceLanguage == TranslationLanguage.simplifiedChinese) {
    final translations = translationDatabase[text];
    if (translations != null) {
      final targetCode = targetLanguage.code;
      return translations[targetCode];
    }
  }

  // Handle English to other languages
  if (sourceLanguage == TranslationLanguage.english) {
    // Search through database for matching English translation
    for (var entry in translationDatabase.entries) {
      if (entry.value['en'] == text) {
        final targetCode = targetLanguage.code;
        return entry.value[targetCode];
      }
    }
  }

  // Handle Japanese to other languages
  if (sourceLanguage == TranslationLanguage.japanese) {
    for (var entry in translationDatabase.entries) {
      if (entry.value['ja'] == text) {
        final targetCode = targetLanguage.code;
        return entry.value[targetCode];
      }
    }
  }

  // Handle Cantonese to other languages
  if (sourceLanguage == TranslationLanguage.cantonese) {
    for (var entry in translationDatabase.entries) {
      if (entry.value['yue'] == text) {
        final targetCode = targetLanguage.code;
        return entry.value[targetCode];
      }
    }
  }

  // Translation not found
  return null;
}

/// Get mock translation for demo purposes
/// This function simulates AI translation when translation is not found in database
String getMockTranslation(String text, TranslationLanguage targetLanguage) {
  // Return a mock translation indicating this would be translated by AI
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  switch (targetLanguage) {
    case TranslationLanguage.english:
      return '[AI Translation to English] $text';
    case TranslationLanguage.japanese:
      return '[AI 翻訳 to Japanese] $text';
    case TranslationLanguage.cantonese:
      return '[AI 翻譯 to Cantonese] $text';
    case TranslationLanguage.simplifiedChinese:
      return '[AI 翻译 to Simplified Chinese] $text';
    case TranslationLanguage.chinese:
    default:
      return text;
  }
}
