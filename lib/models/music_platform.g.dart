// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_platform.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicPlatformAdapter extends TypeAdapter<MusicPlatform> {
  @override
  final int typeId = 2;

  @override
  MusicPlatform read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MusicPlatform.spotify;
      case 1:
        return MusicPlatform.deezer;
      case 2:
        return MusicPlatform.appleMusic;
      case 3:
        return MusicPlatform.youtubeMusic;
      case 4:
        return MusicPlatform.tidal;
      case 5:
        return MusicPlatform.soundCloud;
      case 6:
        return MusicPlatform.unknown;
      default:
        return MusicPlatform.spotify;
    }
  }

  @override
  void write(BinaryWriter writer, MusicPlatform obj) {
    switch (obj) {
      case MusicPlatform.spotify:
        writer.writeByte(0);
        break;
      case MusicPlatform.deezer:
        writer.writeByte(1);
        break;
      case MusicPlatform.appleMusic:
        writer.writeByte(2);
        break;
      case MusicPlatform.youtubeMusic:
        writer.writeByte(3);
        break;
      case MusicPlatform.tidal:
        writer.writeByte(4);
        break;
      case MusicPlatform.soundCloud:
        writer.writeByte(5);
        break;
      case MusicPlatform.unknown:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicPlatformAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
