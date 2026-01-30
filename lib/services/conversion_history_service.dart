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
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/conversion_history_entry.dart';
import '../models/music_platform.dart';
import '../models/track_metadata.dart';

class ConversionHistoryService {
  static final ConversionHistoryService _instance =
      ConversionHistoryService._internal();
  factory ConversionHistoryService() => _instance;
  ConversionHistoryService._internal();

  static const int maxHistorySize = 100;

  final box = Hive.box<ConversionHistoryEntry>('conversion_history');

  Future<bool> addEntry(
    String sourceUrl,
    MusicPlatform sourcePlatform,
    MusicPlatform targetPlatform,
    String targetUrl,
    TrackMetadata? metadata,
  ) async {
    try {
      ConversionHistoryEntry entry = ConversionHistoryEntry(
        timestamp: DateTime.timestamp(),
        sourceUrl: sourceUrl,
        sourcePlatform: sourcePlatform,
        targetPlatform: targetPlatform,
        targetUrl: targetUrl,
        metadata: metadata,
      );

      await box.add(entry);

      int nbOfItems = box.length;

      if (nbOfItems > maxHistorySize) {
        List<ConversionHistoryEntry> items = getEntryList();
        items.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        if (items.firstOrNull != null) {
          await deleteEntry(items.first);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error adding entry to history: $e');

      return false;
    }
  }

  Future<bool> deleteEntry(ConversionHistoryEntry entry) async {
    try {
      for (int key in box.keys) {
        ConversionHistoryEntry? value = box.getAt(key);

        if (value != null &&
            value.timestamp == entry.timestamp &&
            value.sourceUrl == entry.sourceUrl) {
          await box.deleteAt(key);

          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting entry from history: $e');

      return false;
    }
  }

  List<ConversionHistoryEntry> getEntryList() {
    try {
      List<ConversionHistoryEntry> items = box.values.toList();
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return items;
    } catch (e) {
      debugPrint('Error getting history list: $e');

      return [];
    }
  }

  Future<bool> deleteEntryList() async {
    try {
      await box.clear();

      return true;
    } catch (e) {
      debugPrint('Error clearing history: $e');

      return false;
    }
  }
}
