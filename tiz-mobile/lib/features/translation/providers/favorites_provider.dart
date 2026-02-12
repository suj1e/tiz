import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/favorite_translation.dart';

/// Provider for managing favorite translations
/// Uses Hive for local persistence
class FavoritesProvider extends ChangeNotifier {
  static const String _boxName = 'favorite_translations';
  late Box<FavoriteTranslation> _box;

  // Predefined categories
  static const List<String> defaultCategories = [
    '全部',
    '工作',
    '旅行',
    '学习',
    '日常',
  ];

  List<FavoriteTranslation> _favorites = [];
  String _selectedCategory = '全部';

  List<FavoriteTranslation> get favorites {
    if (_selectedCategory == '全部') {
      return _favorites;
    }
    return _favorites.where((f) => f.category == _selectedCategory).toList();
  }

  List<FavoriteTranslation> get allFavorites => _favorites;

  String get selectedCategory => _selectedCategory;

  int get count => _favorites.length;

  FavoritesProvider();

  /// Initialize the Hive box
  Future<void> init() async {
    try {
      _box = await Hive.openBox<FavoriteTranslation>(_boxName);
      _loadFavorites();
    } catch (e) {
      debugPrint('Error initializing favorites box: $e');
      _box = await Hive.openBox<FavoriteTranslation>(_boxName);
      _loadFavorites();
    }
  }

  /// Load favorites from Hive
  void _loadFavorites() {
    _favorites = _box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  /// Check if a translation is already favorited
  bool isFavorited(String sourceText, String targetText) {
    return _favorites.any((f) =>
      f.sourceText == sourceText &&
      f.translatedText == targetText
    );
  }

  /// Add a new favorite translation
  Future<void> addFavorite({
    required String sourceText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    String? category,
  }) async {
    // Check if already exists
    if (isFavorited(sourceText, translatedText)) {
      return;
    }

    final favorite = FavoriteTranslation(
      id: const Uuid().v4(),
      sourceText: sourceText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
      category: category,
    );

    await _box.put(favorite.id, favorite);
    _loadFavorites();
  }

  /// Remove a favorite by id
  Future<void> removeFavorite(String id) async {
    await _box.delete(id);
    _loadFavorites();
  }

  /// Remove a favorite by source and target text
  Future<void> removeByText(String sourceText, String translatedText) async {
    final favorite = _favorites.firstWhere(
      (f) => f.sourceText == sourceText && f.translatedText == translatedText,
      orElse: () => throw Exception('Favorite not found'),
    );
    await removeFavorite(favorite.id);
  }

  /// Update the category of a favorite
  Future<void> updateCategory(String id, String? category) async {
    final favorite = _box.get(id);
    if (favorite != null) {
      final updated = favorite.copyWith(category: category);
      await _box.put(id, updated);
      _loadFavorites();
    }
  }

  /// Set the current category filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Export favorites as CSV
  String exportToCsv() {
    final header = 'Source Text,Translated Text,Source Language,Target Language,Category,Timestamp\n';
    final rows = favorites.map((f) => f.toCsvRow()).join('\n');
    return header + rows;
  }

  /// Export favorites as JSON
  String exportToJson() {
    final data = favorites.map((f) => f.toJson()).toList();
    // Simple JSON string encoding
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < data.length; i++) {
      if (i > 0) buffer.write(',\n');
      buffer.write('  ${_jsonEncode(data[i])}');
    }
    buffer.write('\n]');
    return buffer.toString();
  }

  String _jsonEncode(Map<String, dynamic> data) {
    final buffer = StringBuffer('{');
    var first = true;
    data.forEach((key, value) {
      if (!first) buffer.write(', ');
      first = false;
      buffer.write('"$key": ');
      if (value == null) {
        buffer.write('null');
      } else if (value is String) {
        buffer.write('"${value.replaceAll('"', '\\"')}"');
      } else if (value is DateTime) {
        buffer.write('"${value.toIso8601String()}"');
      } else {
        buffer.write(value);
      }
    });
    buffer.write('}');
    return buffer.toString();
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    await _box.clear();
    _loadFavorites();
  }

  @override
  void dispose() {
    _box.close();
    super.dispose();
  }
}
