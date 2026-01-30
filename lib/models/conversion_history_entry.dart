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
import 'package:hive/hive.dart';
import 'music_platform.dart';
import 'track_metadata.dart';

part 'conversion_history_entry.g.dart';

@HiveType(typeId: 0)
class ConversionHistoryEntry {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final String sourceUrl;

  @HiveField(2)
  final MusicPlatform sourcePlatform;

  @HiveField(3)
  final MusicPlatform targetPlatform;

  @HiveField(4)
  final String targetUrl;

  @HiveField(5)
  final TrackMetadata? metadata;

  ConversionHistoryEntry({
    required this.timestamp,
    required this.sourceUrl,
    required this.sourcePlatform,
    required this.targetPlatform,
    required this.targetUrl,
    this.metadata,
  });

  @override
  String toString() {
    return 'ConversionHistoryEntry(timestamp: $timestamp, '
        'source: ${sourcePlatform.displayName} -> target: ${targetPlatform.displayName}, '
        'track: ${metadata?.title ?? 'Unknown'})';
  }
}
