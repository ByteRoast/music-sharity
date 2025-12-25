/*
 * Music Sharity - Convert music links between streaming platforms
 * Copyright (C) 2025 Sikelio (Byte Roast)
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
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/track_metadata.dart';

class OdesliResult {
  final Map<String, String> platformLinks;
  final TrackMetadata? metadata;

  OdesliResult({required this.platformLinks, this.metadata});
}

class OdesliService {
  static const String _baseUrl = 'https://api.song.link/v1-alpha.1/links';

  static final OdesliService _instance = OdesliService._internal();
  factory OdesliService() => _instance;
  OdesliService._internal();

  Future<OdesliResult> convertLink(String sourceUrl) async {
    final encodedUrl = Uri.encodeComponent(sourceUrl);
    final response = await http.get(Uri.parse('$_baseUrl?url=$encodedUrl'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final platformLinks = _extractPlatformLinks(data);
      final metadata = _extractMetadata(data);

      return OdesliResult(platformLinks: platformLinks, metadata: metadata);
    } else {
      throw Exception(
        'Odesli API error: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Map<String, String> _extractPlatformLinks(Map<String, dynamic> data) {
    final linksByPlatform = data['linksByPlatform'] as Map<String, dynamic>?;

    if (linksByPlatform == null) {
      throw Exception('No links found for this track');
    }

    final Map<String, String> platformLinks = {};

    if (linksByPlatform['appleMusic'] != null) {
      platformLinks['appleMusic'] = linksByPlatform['appleMusic']['url'];
    }

    if (linksByPlatform['spotify'] != null) {
      platformLinks['spotify'] = linksByPlatform['spotify']['url'];
    }

    if (linksByPlatform['deezer'] != null) {
      platformLinks['deezer'] = linksByPlatform['deezer']['url'];
    }

    if (linksByPlatform['youtubeMusic'] != null) {
      platformLinks['youtubeMusic'] = linksByPlatform['youtubeMusic']['url'];
    }

    if (linksByPlatform['tidal'] != null) {
      platformLinks['tidal'] = linksByPlatform['tidal']['url'];
    }

    return platformLinks;
  }

  TrackMetadata? _extractMetadata(Map<String, dynamic> data) {
    try {
      final entitiesByUniqueId =
          data['entitiesByUniqueId'] as Map<String, dynamic>?;

      if (entitiesByUniqueId == null || entitiesByUniqueId.isEmpty) {
        return null;
      }

      final entityUniqueId = data['entityUniqueId'] as String?;
      Map<String, dynamic>? entity;

      if (entityUniqueId != null &&
          entitiesByUniqueId.containsKey(entityUniqueId)) {
        entity = entitiesByUniqueId[entityUniqueId] as Map<String, dynamic>;
      } else {
        entity = entitiesByUniqueId.values.first as Map<String, dynamic>;
      }

      return TrackMetadata(
        title: entity['title'] ?? 'Unknown Title',
        artist: entity['artistName'] ?? 'Unknown Artist',
        album: entity['title'],
        imageUrl: entity['thumbnailUrl'],
      );
    } catch (e) {
      return null;
    }
  }
}
