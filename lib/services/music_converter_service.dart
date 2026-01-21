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
import 'odesli_service.dart';
import '../models/content_type.dart';
import '../models/music_link.dart';
import '../models/music_platform.dart';
import '../models/track_metadata.dart';

class ConversionResult {
  final String? url;
  final TrackMetadata? metadata;
  final String? error;
  final ContentType? contentType;

  ConversionResult({this.url, this.metadata, this.error, this.contentType});

  bool get isSuccess => url != null && error == null;
}

class MusicConverterService {
  final OdesliService _odesliService = OdesliService();

  static final MusicConverterService _instance =
      MusicConverterService._internal();
  factory MusicConverterService() => _instance;
  MusicConverterService._internal();

  Future<ConversionResult> convert(
    MusicLink sourceLink,
    MusicPlatform targetPlatform,
  ) async {
    try {
      final result = await _odesliService.convertLink(sourceLink.originalUrl);

      String? targetUrl;
      switch (targetPlatform) {
        case MusicPlatform.spotify:
          targetUrl = result.platformLinks['spotify'];
          break;
        case MusicPlatform.deezer:
          targetUrl = result.platformLinks['deezer'];
          break;
        case MusicPlatform.appleMusic:
          targetUrl = result.platformLinks['appleMusic'];
          break;
        case MusicPlatform.youtubeMusic:
          targetUrl = result.platformLinks['youtubeMusic'];
          break;
        case MusicPlatform.tidal:
          targetUrl = result.platformLinks['tidal'];
          break;
        default:
          break;
      }

      ConversionResult conversionResult;

      targetUrl != null
          ? conversionResult = ConversionResult(
              url: targetUrl,
              metadata: result.metadata,
              contentType: sourceLink.contentType,
            )
          : conversionResult = ConversionResult(
              metadata: result.metadata,
              error: 'Content not found on target platform',
              contentType: sourceLink.contentType,
            );

      return conversionResult;
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }
}
