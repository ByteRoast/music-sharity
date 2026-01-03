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
