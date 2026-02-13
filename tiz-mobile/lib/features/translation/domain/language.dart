enum Language {
  en('English', 'en'),
  yue('粤语', 'yue'),
  szc('川语', 'szc'),
  zh('中文', 'zh');

  final String label;
  final String code;

  const Language(this.label, this.code);

  static Language? fromCode(String code) {
    for (final lang in values) {
      if (lang.code == code) return lang;
    }
    return null;
  }
}
