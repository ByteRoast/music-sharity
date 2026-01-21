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
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'rate_limiter_service.dart';
import '../models/track_metadata.dart';

class OdesliResult {
  final Map<String, String> platformLinks;
  final TrackMetadata? metadata;

  OdesliResult({required this.platformLinks, this.metadata});
}

class OdesliService {
  static const String _baseUrl = 'https://api.song.link/v1-alpha.1/links';
  static const String _cloudflareWorkerUrl =
      'https://music-sharity-proxy.byteroast.workers.dev';

  static final OdesliService _instance = OdesliService._internal();
  factory OdesliService() => _instance;
  OdesliService._internal();

  final RateLimiterService _rateLimiter = RateLimiterService();
  final Map<String, _CacheEntry> _cache = {};

  static const Duration _cacheDuration = Duration(hours: 1);

  Future<OdesliResult> convertLink(String sourceUrl) async {
    _cleanExpiredCache();

    final cachedResult = _cache[sourceUrl];
    if (cachedResult != null && !cachedResult.isExpired) {
      return cachedResult.result;
    }

    return await _rateLimiter.executeWithRateLimit(() async {
      final encodedUrl = Uri.encodeComponent(sourceUrl);

      final String finalUrl = kIsWeb
          ? '$_cloudflareWorkerUrl?url=$encodedUrl'
          : '$_baseUrl?url=$encodedUrl';

      final response = await http.get(Uri.parse(finalUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final platformLinks = _extractPlatformLinks(data);
        final metadata = _extractMetadata(data);
        final result = OdesliResult(
          platformLinks: platformLinks,
          metadata: metadata,
        );

        _cache[sourceUrl] = _CacheEntry(result);

        return result;
      } else if (response.statusCode == 429) {
        throw RateLimitException(
          'Rate limit exceeded by server. Please try again in a moment.',
          const Duration(seconds: 60),
        );
      } else {
        throw Exception(
          'Odesli API error: ${response.statusCode} - ${response.body}',
        );
      }
    });
  }

  void _cleanExpiredCache() {
    _cache.removeWhere((key, value) => value.isExpired);
  }

  int get remainingQuota => _rateLimiter.remainingQuota;

  Duration? get timeUntilNextRequest => _rateLimiter.timeUntilNextAvailable;

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

      (entityUniqueId != null && entitiesByUniqueId.containsKey(entityUniqueId))
          ? entity = entitiesByUniqueId[entityUniqueId] as Map<String, dynamic>
          : entity = entitiesByUniqueId.values.first as Map<String, dynamic>;

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

class _CacheEntry {
  final OdesliResult result;
  final DateTime timestamp;

  _CacheEntry(this.result) : timestamp = DateTime.now();

  bool get isExpired {
    return DateTime.now().difference(timestamp) > OdesliService._cacheDuration;
  }
}
