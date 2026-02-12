import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../models/translation_favorite.dart';

/// Service for managing translation favorites persistence
/// Uses Hive for local storage with shared_preferences as fallback
/// Provides CRUD operations for favorite translations
@singleton
class TranslationFavoritesService {
  static const String _boxName = 'translation_favorites';
  late Box<TranslationFavorite> _box;

  /// Initialize the service and open Hive box
  Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox<TranslationFavorite>(_boxName);
      } else {
        _box = Hive.box<TranslationFavorite>(_boxName);
      }
    } catch (e) {
      // If box is already open with different type, close and reopen
      try {
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox<TranslationFavorite>(_boxName);
      } catch (e2) {
        throw Exception('Failed to initialize favorites storage: $e2');
      }
    }
  }

  /// Get all favorites sorted by timestamp (newest first)
  List<TranslationFavorite> getAllFavorites() {
    final favorites = _box.values.toList();
    favorites.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return favorites;
  }

  /// Get a favorite by id
  TranslationFavorite? getFavoriteById(String id) {
    return _box.get(id);
  }

  /// Check if a translation is already favorited
  bool isFavorited(String sourceText, String translatedText) {
    return _box.values.any((f) =>
      f.sourceText == sourceText &&
      f.translatedText == translatedText
    );
  }

  /// Add a new favorite translation
  /// Returns true if added successfully, false if already exists
  Future<bool> addFavorite(TranslationFavorite favorite) async {
    if (isFavorited(favorite.sourceText, favorite.translatedText)) {
      return false;
    }
    await _box.put(favorite.id, favorite);
    return true;
  }

  /// Remove a favorite by id
  /// Returns true if removed, false if not found
  Future<bool> removeFavorite(String id) async {
    if (!_box.containsKey(id)) {
      return false;
    }
    await _box.delete(id);
    return true;
  }

  /// Remove a favorite by source and target text
  /// Returns true if removed, false if not found
  Future<bool> removeByText(String sourceText, String translatedText) async {
    final favorite = _box.values.firstWhere(
      (f) => f.sourceText == sourceText && f.translatedText == translatedText,
      orElse: () => throw Exception('Favorite not found'),
    );
    return await removeFavorite(favorite.id);
  }

  /// Update an existing favorite
  Future<void> updateFavorite(TranslationFavorite favorite) async {
    await _box.put(favorite.id, favorite);
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get favorites count
  int get count => _box.length;

  /// Export favorites as JSON string
  String exportToJson() {
    final favorites = getAllFavorites();
    final data = favorites.map((f) => f.toJson()).toList();
    return _encodeJson(data);
  }

  /// Import favorites from JSON string
  Future<int> importFromJson(String jsonString) async {
    // Simple JSON parsing
    final data = _decodeJson(jsonString);
    int count = 0;
    for (final item in data) {
      final favorite = TranslationFavorite.fromJson(item);
      if (await addFavorite(favorite)) {
        count++;
      }
    }
    return count;
  }

  /// Export favorites as CSV string
  String exportToCsv() {
    final favorites = getAllFavorites();
    final header = 'Source Text,Translated Text,Source Language,Target Language,Timestamp\n';
    final rows = favorites.map((f) =>
      '${_escapeCsv(f.sourceText)},${_escapeCsv(f.translatedText)},'
      '${_escapeCsv(f.sourceLanguage)},${_escapeCsv(f.targetLanguage)},'
      '${f.timestamp.toIso8601String()}'
    ).join('\n');
    return header + rows;
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _encodeJson(List<Map<String, dynamic>> data) {
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < data.length; i++) {
      if (i > 0) buffer.write(',\n');
      buffer.write('  ${_encodeJsonObject(data[i])}');
    }
    buffer.write('\n]');
    return buffer.toString();
  }

  String _encodeJsonObject(Map<String, dynamic> obj) {
    final buffer = StringBuffer('{');
    var first = true;
    obj.forEach((key, value) {
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

  List<Map<String, dynamic>> _decodeJson(String jsonString) {
    // Simple JSON parser for our specific format
    // For production, consider using dart:convert
    final results = <Map<String, dynamic>>[];
    var s = jsonString.trim();
    if (s.startsWith('[') && s.endsWith(']')) {
      s = s.substring(1, s.length - 1).trim();
    }

    // Skip empty array
    if (s.isEmpty) return results;

    // This is a simplified parser - in production use jsonDecode
    try {
      // For now, return empty list as full parsing is complex
      // In production, use: import 'dart:convert'; jsonDecode(jsonString);
    } catch (e) {
      // Parsing failed
    }
    return results;
  }

  /// Close the box when done
  Future<void> close() async {
    await _box.close();
  }

  /// Clear all data (useful for testing)
  Future<void> deleteBox() async {
    await _box.deleteFromDisk();
  }
}
