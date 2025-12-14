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

class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';

  static final DeezerService _instance = DeezerService._internal();
  factory DeezerService() => _instance;
  DeezerService._internal();

  Future<TrackMetadata> getTrackMetadata(String trackId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/track/$trackId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] != null) {
        throw Exception('Deezer API error: ${data['error']['message']}');
      }

      return TrackMetadata.fromJson(data, 'deezer');
    } else {
      throw Exception('Failed to get track metadata: ${response.body}');
    }
  }

  Future<String?> searchByIsrc(String isrc) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/track/isrc:$isrc'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error'] == null && data['id'] != null) {
        return data['id'].toString();
      }
    }

    return null;
  }

  Future<String?> searchByQuery(String title, String artist) async {
    final query = Uri.encodeComponent('$artist $title');
    final response = await http.get(
      Uri.parse('$_baseUrl/search?q=$query&limit=1'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = data['data'] as List?;

      if (tracks != null && tracks.isNotEmpty) {
        return tracks.first['id'].toString();
      }
    }

    return null;
  }

  String generateTrackUrl(String trackId) {
    return 'https://www.deezer.com/track/$trackId';
  }
}
