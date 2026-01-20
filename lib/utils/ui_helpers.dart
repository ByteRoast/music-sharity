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
import 'package:flutter/material.dart';
import 'link_validator.dart';

class UiHelpers {
  static String getPlatformName(MusicPlatform platform) {
    switch (platform) {
      case MusicPlatform.spotify:
        return 'Spotify';
      case MusicPlatform.deezer:
        return 'Deezer';
      case MusicPlatform.appleMusic:
        return 'Apple Music';
      case MusicPlatform.youtubeMusic:
        return 'YouTube Music';
      case MusicPlatform.tidal:
        return 'Tidal';
      case MusicPlatform.soundCloud:
        return 'SoundCloud';
      default:
        return 'Unknown';
    }
  }

  static String getPlatformLogo(MusicPlatform platform) {
    switch (platform) {
      case MusicPlatform.spotify:
        return 'assets/images/platforms/spotify.png';
      case MusicPlatform.deezer:
        return 'assets/images/platforms/deezer.png';
      case MusicPlatform.appleMusic:
        return 'assets/images/platforms/apple-music.png';
      case MusicPlatform.youtubeMusic:
        return 'assets/images/platforms/youtube-music.png';
      case MusicPlatform.tidal:
        return 'assets/images/platforms/tidal.png';
      case MusicPlatform.soundCloud:
        return 'assets/images/platforms/soundcloud.png';
      default:
        return '';
    }
  }

  static String getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.track:
        return 'Track';
      case ContentType.album:
        return 'Album';
      case ContentType.shortLink:
        return 'Shared Link';
      default:
        return 'Unknown';
    }
  }

  static IconData getContentIcon(ContentType type) {
    switch (type) {
      case ContentType.track:
        return Icons.music_note;
      case ContentType.album:
        return Icons.album;
      case ContentType.shortLink:
        return Icons.link;
      default:
        return Icons.music_note;
    }
  }
}
