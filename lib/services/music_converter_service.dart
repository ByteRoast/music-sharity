import 'package:flutter/foundation.dart';
import 'spotify_service.dart';
import 'deezer_service.dart';
import 'odesli_service.dart';
import '../models/music_link.dart';
import '../models/track_metadata.dart';
import '../utils/link_validator.dart';

class ConversionResult {
  final String? url;
  final TrackMetadata? metadata;
  final String? error;
  final ContentType? contentType;

  ConversionResult({this.url, this.metadata, this.error, this.contentType});

  bool get isSuccess => url != null && error == null;
}

class MusicConverterService {
  final SpotifyService _spotifyService = SpotifyService();
  final DeezerService _deezerService = DeezerService();
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
      if (sourceLink.isAlbum) {
        return await _convertViaOdesli(sourceLink, targetPlatform);
      }

      if (sourceLink.sourcePlatform == MusicPlatform.appleMusic ||
          sourceLink.sourcePlatform == MusicPlatform.youtubeMusic ||
          sourceLink.sourcePlatform == MusicPlatform.tidal) {
        return await _convertFromOdesliSource(sourceLink, targetPlatform);
      }

      if (targetPlatform == MusicPlatform.appleMusic ||
          targetPlatform == MusicPlatform.youtubeMusic ||
          targetPlatform == MusicPlatform.tidal) {
        return await _convertToOdesliTarget(sourceLink, targetPlatform);
      }

      return await _convertDirect(sourceLink, targetPlatform);
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }

  Future<ConversionResult> _convertViaOdesli(
    MusicLink sourceLink,
    MusicPlatform targetPlatform,
  ) async {
    try {
      final platformLinks = await _odesliService.convertLink(
        sourceLink.originalUrl,
      );

      String? targetUrl;
      switch (targetPlatform) {
        case MusicPlatform.spotify:
          targetUrl = platformLinks['spotify'];
          break;
        case MusicPlatform.deezer:
          targetUrl = platformLinks['deezer'];
          break;
        case MusicPlatform.appleMusic:
          targetUrl = platformLinks['appleMusic'];
          break;
        case MusicPlatform.youtubeMusic:
          targetUrl = platformLinks['youtubeMusic'];
          break;
        case MusicPlatform.tidal:
          targetUrl = platformLinks['tidal'];
          break;
        default:
          break;
      }

      if (targetUrl != null) {
        return ConversionResult(
          url: targetUrl,
          metadata: null,
          contentType: sourceLink.contentType,
        );
      } else {
        return ConversionResult(
          metadata: null,
          error: 'Content not found on target platform',
          contentType: sourceLink.contentType,
        );
      }
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }

  Future<ConversionResult> _convertFromOdesliSource(
    MusicLink sourceLink,
    MusicPlatform targetPlatform,
  ) async {
    try {
      final platformLinks = await _odesliService.convertLink(
        sourceLink.originalUrl,
      );

      String? targetUrl;
      switch (targetPlatform) {
        case MusicPlatform.spotify:
          targetUrl = platformLinks['spotify'];
          break;
        case MusicPlatform.deezer:
          targetUrl = platformLinks['deezer'];
          break;
        case MusicPlatform.appleMusic:
          targetUrl = platformLinks['appleMusic'];
          break;
        case MusicPlatform.youtubeMusic:
          targetUrl = platformLinks['youtubeMusic'];
          break;
        case MusicPlatform.tidal:
          targetUrl = platformLinks['tidal'];
          break;
        default:
          break;
      }

      if (targetUrl != null) {
        return ConversionResult(
          url: targetUrl,
          metadata: null,
          contentType: sourceLink.contentType,
        );
      } else {
        return ConversionResult(
          metadata: null,
          error: 'Track not found on target platform',
          contentType: sourceLink.contentType,
        );
      }
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }

  Future<ConversionResult> _convertToOdesliTarget(
    MusicLink sourceLink,
    MusicPlatform targetPlatform,
  ) async {
    try {
      TrackMetadata? metadata;
      try {
        metadata = await _getSourceMetadata(sourceLink);
      } catch (e) {
        debugPrint('Could not fetch metadata: $e');
      }

      final platformLinks = await _odesliService.convertLink(
        sourceLink.originalUrl,
      );

      String? targetUrl;
      switch (targetPlatform) {
        case MusicPlatform.appleMusic:
          targetUrl = platformLinks['appleMusic'];
          break;
        case MusicPlatform.youtubeMusic:
          targetUrl = platformLinks['youtubeMusic'];
          break;
        case MusicPlatform.tidal:
          targetUrl = platformLinks['tidal'];
          break;
        default:
          break;
      }

      if (targetUrl != null) {
        return ConversionResult(
          url: targetUrl,
          metadata: metadata,
          contentType: sourceLink.contentType,
        );
      } else {
        return ConversionResult(
          metadata: metadata,
          error: 'Track not found on target platform',
          contentType: sourceLink.contentType,
        );
      }
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }

  Future<ConversionResult> _convertDirect(
    MusicLink sourceLink,
    MusicPlatform targetPlatform,
  ) async {
    try {
      TrackMetadata metadata = await _getSourceMetadata(sourceLink);

      String? targetTrackId;

      if (metadata.isrc != null) {
        targetTrackId = await _searchByIsrc(metadata.isrc!, targetPlatform);
      }

      targetTrackId ??= await _searchByQuery(
        metadata.title,
        metadata.artist,
        targetPlatform,
      );

      if (targetTrackId != null) {
        final url = _generateUrl(targetTrackId, targetPlatform);
        return ConversionResult(
          url: url,
          metadata: metadata,
          contentType: ContentType.track,
        );
      } else {
        return ConversionResult(
          metadata: metadata,
          error: 'Track not found on target platform',
          contentType: ContentType.track,
        );
      }
    } catch (e) {
      return ConversionResult(error: e.toString());
    }
  }

  Future<TrackMetadata> _getSourceMetadata(MusicLink sourceLink) async {
    switch (sourceLink.sourcePlatform) {
      case MusicPlatform.spotify:
        return await _spotifyService.getTrackMetadata(sourceLink.trackId!);
      case MusicPlatform.deezer:
        return await _deezerService.getTrackMetadata(sourceLink.trackId!);
      default:
        throw Exception('Source platform not supported yet');
    }
  }

  Future<String?> _searchByIsrc(String isrc, MusicPlatform platform) async {
    switch (platform) {
      case MusicPlatform.spotify:
        return await _spotifyService.searchByIsrc(isrc);
      case MusicPlatform.deezer:
        return await _deezerService.searchByIsrc(isrc);
      default:
        return null;
    }
  }

  Future<String?> _searchByQuery(
    String title,
    String artist,
    MusicPlatform platform,
  ) async {
    switch (platform) {
      case MusicPlatform.deezer:
        return await _deezerService.searchByQuery(title, artist);
      default:
        return null;
    }
  }

  String _generateUrl(String trackId, MusicPlatform platform) {
    switch (platform) {
      case MusicPlatform.spotify:
        return _spotifyService.generateTrackUrl(trackId);
      case MusicPlatform.deezer:
        return _deezerService.generateTrackUrl(trackId);
      default:
        throw Exception('Platform not supported');
    }
  }
}
