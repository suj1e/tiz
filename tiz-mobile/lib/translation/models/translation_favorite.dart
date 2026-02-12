import 'package:hive/hive.dart';

part 'translation_favorite.g.dart';

/// Translation favorite model
/// Stored locally using Hive for persistence
/// This model represents a single favorited translation
@HiveType(typeId: 1)
class TranslationFavorite extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sourceText;

  @HiveField(2)
  final String translatedText;

  @HiveField(3)
  final String sourceLanguage;

  @HiveField(4)
  final String targetLanguage;

  @HiveField(5)
  final DateTime timestamp;

  TranslationFavorite({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  /// Create from JSON (for import/export functionality)
  factory TranslationFavorite.fromJson(Map<String, dynamic> json) =>
      TranslationFavorite(
        id: json['id'] as String,
        sourceText: json['sourceText'] as String,
        translatedText: json['translatedText'] as String,
        sourceLanguage: json['sourceLanguage'] as String,
        targetLanguage: json['targetLanguage'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  /// Convert to JSON (for export functionality)
  Map<String, dynamic> toJson() => {
        'id': id,
        'sourceText': sourceText,
        'translatedText': translatedText,
        'sourceLanguage': sourceLanguage,
        'targetLanguage': targetLanguage,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Create a copy with updated fields
  TranslationFavorite copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
  }) =>
      TranslationFavorite(
        id: id ?? this.id,
        sourceText: sourceText ?? this.sourceText,
        translatedText: translatedText ?? this.translatedText,
        sourceLanguage: sourceLanguage ?? this.sourceLanguage,
        targetLanguage: targetLanguage ?? this.targetLanguage,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationFavorite &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TranslationFavorite(id: $id, sourceText: $sourceText, '
      'translatedText: $translatedText, sourceLanguage: $sourceLanguage, '
      'targetLanguage: $targetLanguage, timestamp: $timestamp)';
}
