import 'dart:convert';
import 'package:http/http.dart' as http;

class OdesliService {
  static const String _baseUrl = 'https://api.song.link/v1-alpha.1/links';

  static final OdesliService _instance = OdesliService._internal();
  factory OdesliService() => _instance;
  OdesliService._internal();

  Future<Map<String, String>> convertLink(String sourceUrl) async {
    final encodedUrl = Uri.encodeComponent(sourceUrl);
    final response = await http.get(Uri.parse('$_baseUrl?url=$encodedUrl'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
    } else {
      throw Exception(
        'Odesli API error: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
