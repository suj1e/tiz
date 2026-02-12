import 'package:hive/hive.dart';

part 'favorite_translation.g.dart';

/// Favorite translation model
/// Stored locally using Hive for persistence
@HiveType(typeId: 0)
class FavoriteTranslation extends HiveObject {
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

  @HiveField(6)
  final String? category;

  FavoriteTranslation({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.category,
  });

  /// Create a FavoriteTranslation from a map
  factory FavoriteTranslation.fromJson(Map<String, dynamic> json) => FavoriteTranslation(
    id: json['id'] as String,
    sourceText: json['sourceText'] as String,
    translatedText: json['translatedText'] as String,
    sourceLanguage: json['sourceLanguage'] as String,
    targetLanguage: json['targetLanguage'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    category: json['category'] as String?,
  );

  /// Convert to JSON for export
  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceText': sourceText,
    'translatedText': translatedText,
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'timestamp': timestamp.toIso8601String(),
    'category': category,
  };

  /// Convert to CSV row
  String toCsvRow() => '$sourceText,$translatedText,$sourceLanguage,$targetLanguage,${category ?? ''},${timestamp.toIso8601String()}';

  /// Create a copy with updated fields
  FavoriteTranslation copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    String? category,
  }) => FavoriteTranslation(
    id: id ?? this.id,
    sourceText: sourceText ?? this.sourceText,
    translatedText: translatedText ?? this.translatedText,
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    timestamp: timestamp ?? this.timestamp,
    category: category ?? this.category,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is FavoriteTranslation &&
        runtimeType == other.runtimeType &&
        id == other.id;

  @override
  int get hashCode => id.hashCode;
}
