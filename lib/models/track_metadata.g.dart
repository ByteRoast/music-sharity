// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackMetadataAdapter extends TypeAdapter<TrackMetadata> {
  @override
  final int typeId = 1;

  @override
  TrackMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackMetadata(
      title: fields[0] as String,
      artist: fields[1] as String,
      album: fields[2] as String?,
      imageUrl: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.artist)
      ..writeByte(2)
      ..write(obj.album)
      ..writeByte(3)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
