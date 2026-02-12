// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_translation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteTranslationAdapter extends TypeAdapter<FavoriteTranslation> {
  @override
  final int typeId = 0;

  @override
  FavoriteTranslation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteTranslation(
      id: fields[0] as String,
      sourceText: fields[1] as String,
      translatedText: fields[2] as String,
      sourceLanguage: fields[3] as String,
      targetLanguage: fields[4] as String,
      timestamp: fields[5] as DateTime,
      category: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteTranslation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceText)
      ..writeByte(2)
      ..write(obj.translatedText)
      ..writeByte(3)
      ..write(obj.sourceLanguage)
      ..writeByte(4)
      ..write(obj.targetLanguage)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteTranslationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
