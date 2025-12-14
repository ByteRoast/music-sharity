enum MusicPlatform { spotify, deezer, appleMusic, youtubeMusic, tidal, unknown }

enum ContentType { track, album, unknown }

class LinkValidator {
  static final Map<MusicPlatform, RegExp> platformPatterns = {
    MusicPlatform.spotify: RegExp(
      r'open\.spotify\.com/(intl-[a-z]{2}/|)(track|album)/([a-zA-Z0-9]+)',
    ),
    MusicPlatform.deezer: RegExp(
      r'deezer\.com/(intl-[a-z]{2}/|)(track|album)/(\d+)',
    ),
    MusicPlatform.appleMusic: RegExp(
      r'music\.apple\.com/[a-z]{2}/(album|song)/([^?]+)',
    ),
    MusicPlatform.youtubeMusic: RegExp(
      r'music\.youtube\.com/watch\?v=([a-zA-Z0-9_-]+)',
    ),
    MusicPlatform.tidal: RegExp(r'tidal\.com/(track|album)/(\d+)'),
  };

  static MusicPlatform detectPlatform(String url) {
    for (MapEntry<MusicPlatform, RegExp> entry in platformPatterns.entries) {
      if (entry.value.hasMatch(url)) {
        return entry.key;
      }
    }
    return MusicPlatform.unknown;
  }

  static ContentType detectContentType(String url) {
    if (url.contains('/track/') ||
        url.contains('/song/') ||
        url.contains('watch?v=')) {
      return ContentType.track;
    } else if (url.contains('/album/')) {
      return ContentType.album;
    }
    return ContentType.unknown;
  }

  static bool isValidMusicLink(String url) {
    return detectPlatform(url) != MusicPlatform.unknown &&
        detectContentType(url) != ContentType.unknown;
  }

  static String? extractId(String url, MusicPlatform platform) {
    final pattern = platformPatterns[platform];
    if (pattern == null) return null;

    final match = pattern.firstMatch(url);
    if (match == null) return null;

    return match.group(match.groupCount);
  }
}
