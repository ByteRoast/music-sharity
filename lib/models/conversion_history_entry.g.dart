// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversion_history_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversionHistoryEntryAdapter
    extends TypeAdapter<ConversionHistoryEntry> {
  @override
  final int typeId = 0;

  @override
  ConversionHistoryEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversionHistoryEntry(
      timestamp: fields[0] as DateTime,
      sourceUrl: fields[1] as String,
      sourcePlatform: fields[2] as MusicPlatform,
      targetPlatform: fields[3] as MusicPlatform,
      targetUrl: fields[4] as String,
      metadata: fields[5] as TrackMetadata?,
    );
  }

  @override
  void write(BinaryWriter writer, ConversionHistoryEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.sourceUrl)
      ..writeByte(2)
      ..write(obj.sourcePlatform)
      ..writeByte(3)
      ..write(obj.targetPlatform)
      ..writeByte(4)
      ..write(obj.targetUrl)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionHistoryEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
