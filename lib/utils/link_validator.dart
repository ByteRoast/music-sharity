/*
 * Music Sharity - Share music across all platforms
 * Copyright (C) 2026 Sikelio (Byte Roast)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
enum MusicPlatform { spotify, deezer, appleMusic, youtubeMusic, tidal, soundCloud, unknown }

enum ContentType { track, album, shortLink, unknown }

class LinkValidator {
  static final Map<MusicPlatform, RegExp> platformPatterns = {
    MusicPlatform.spotify: RegExp(
      r'open\.spotify\.com/(intl-[a-z]{2}/|)(track|album)/([a-zA-Z0-9]+)',
    ),
    MusicPlatform.deezer: RegExp(
      r'(deezer\.com/(intl-[a-z]{2}/|)(track|album)/(\d+)|link\.deezer\.com/s/[a-zA-Z0-9]+)',
    ),
    MusicPlatform.appleMusic: RegExp(
      r'music\.apple\.com/[a-z]{2}/(album|song)/([^?]+)',
    ),
    MusicPlatform.youtubeMusic: RegExp(
      r'music\.youtube\.com/watch\?v=([a-zA-Z0-9_-]+)',
    ),
    MusicPlatform.tidal: RegExp(r'tidal\.com/(browse/)?(track|album)/(\d+)'),
    MusicPlatform.soundCloud: RegExp(
      r'(on\.soundcloud\.com/[a-zA-Z0-9]+|soundcloud\.com/[^/\s?]+/[^/\s?]+)',
    ),
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
    if (url.contains('link.deezer.com/s/') ||
        url.contains('on.soundcloud.com/')) {
      return ContentType.shortLink;
    }

    if (url.contains('/album/') ||
        (url.contains('soundcloud.com/') && url.contains('/sets/'))) {
      return ContentType.album;
    }

    if (url.contains('/track/') ||
        url.contains('/song/') ||
        url.contains('watch?v=') ||
        RegExp(r'soundcloud\.com/[^/\s?]+/[^/\s?]+').hasMatch(url)) {
      return ContentType.track;
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
