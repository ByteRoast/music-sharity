import '../utils/link_validator.dart';

class MusicLink {
  final String originalUrl;
  final MusicPlatform sourcePlatform;
  final ContentType contentType;
  final String? trackId;

  MusicLink({
    required this.originalUrl,
    required this.sourcePlatform,
    required this.contentType,
    this.trackId,
  });

  factory MusicLink.fromUrl(String url) {
    final platform = LinkValidator.detectPlatform(url);
    final contentType = LinkValidator.detectContentType(url);
    final trackId = LinkValidator.extractId(url, platform);

    return MusicLink(
      originalUrl: url,
      sourcePlatform: platform,
      contentType: contentType,
      trackId: trackId,
    );
  }

  bool get isTrack => contentType == ContentType.track;
  bool get isAlbum => contentType == ContentType.album;
}
