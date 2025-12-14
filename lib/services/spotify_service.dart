import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/track_metadata.dart';

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  static const String _authUrl = 'https://accounts.spotify.com/api/token';

  String? _accessToken;
  DateTime? _tokenExpiry;

  static final SpotifyService _instance = SpotifyService._internal();
  factory SpotifyService() => _instance;

  SpotifyService._internal();

  Future<void> _authenticate() async {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID'];
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET'];

    if (clientId == null || clientSecret == null) {
      throw Exception('Spotify credentials not found in .env file');
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse(_authUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] - 60),
      );
    } else {
      throw Exception('Failed to authenticate with Spotify: ${response.body}');
    }
  }

  Future<String> _getValidToken() async {
    if (_accessToken == null || 
        _tokenExpiry == null || 
        DateTime.now().isAfter(_tokenExpiry!)) {
      await _authenticate();
    }

    return _accessToken!;
  }
  
  Future<TrackMetadata> getTrackMetadata(String trackId) async {
    final token = await _getValidToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/tracks/$trackId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TrackMetadata.fromJson(data, 'spotify');
    } else {
      throw Exception('Failed to get track metadata: ${response.body}');
    }
  }
  
  Future<String?> searchByIsrc(String isrc) async {
    final token = await _getValidToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/search?q=isrc:$isrc&type=track&limit=1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final tracks = data['tracks']?['items'] as List?;

      if (tracks != null && tracks.isNotEmpty) {
        return tracks.first['id'];
      }
    }

    return null;
  }

  String generateTrackUrl(String trackId) {
    return 'https://open.spotify.com/track/$trackId';
  }
}
