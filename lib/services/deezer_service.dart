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
