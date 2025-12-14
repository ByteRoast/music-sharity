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
class TrackMetadata {
  final String title;
  final String artist;
  final String? album;
  final String? isrc;
  final String? imageUrl;
  final int? durationMs;

  TrackMetadata({
    required this.title,
    required this.artist,
    this.album,
    this.isrc,
    this.imageUrl,
    this.durationMs,
  });

  factory TrackMetadata.fromJson(Map<String, dynamic> json, String source) {
    switch (source) {
      case 'spotify':
        return TrackMetadata._fromSpotify(json);
      case 'deezer':
        return TrackMetadata._fromDeezer(json);
      default:
        throw Exception('Unsupported source: $source');
    }
  }

  factory TrackMetadata._fromSpotify(Map<String, dynamic> json) {
    return TrackMetadata(
      title: json['name'] ?? '',
      artist: (json['artists'] as List?)
        ?.map((a) => a['name'] as String)
        .join(', ') ?? '',
      album: json['album']?['name'],
      isrc: json['external_ids']?['isrc'],
      imageUrl: (json['album']?['images'] as List?)?.first?['url'],
      durationMs: json['duration_ms'],
    );
  }
  factory TrackMetadata._fromDeezer(Map<String, dynamic> json) {
    return TrackMetadata(
      title: json['title'] ?? '',
      artist: json['artist']?['name'] ?? '',
      album: json['album']?['title'],
      isrc: json['isrc'],
      imageUrl: json['album']?['cover_xl'],
      durationMs: (json['duration'] as int?) != null 
        ? (json['duration'] as int) * 1000 
        : null,
    );
  }

  @override
  String toString() {
    return '$title - $artist${album != null ? ' ($album)' : ''}';
  }
}
