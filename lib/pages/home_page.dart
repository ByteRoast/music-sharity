import 'package:flutter/material.dart';
import 'conversion_page.dart';
import '../utils/link_validator.dart';
import '../models/music_link.dart';

class HomePage extends StatefulWidget {
  final String? initialLink;

  const HomePage({super.key, this.initialLink});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _linkController = TextEditingController();

  MusicPlatform? _detectedPlatform;
  bool _isValidLink = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialLink != null && widget.initialLink!.isNotEmpty) {
      _linkController.text = widget.initialLink!;
      _validateLink(widget.initialLink!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isValidLink) {
          final musicLink = MusicLink.fromUrl(_linkController.text);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversionPage(musicLink: musicLink),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _validateLink(String url) {
    setState(() {
      if (url.isEmpty) {
        _detectedPlatform = null;
        _isValidLink = false;
      } else {
        _detectedPlatform = LinkValidator.detectPlatform(url);
        _isValidLink = _detectedPlatform != MusicPlatform.unknown;
      }
    });
  }

  String _getPlatformName(MusicPlatform platform) {
    switch (platform) {
      case MusicPlatform.spotify:
        return 'Spotify';
      case MusicPlatform.deezer:
        return 'Deezer';
      case MusicPlatform.appleMusic:
        return 'Apple Music';
      case MusicPlatform.youtubeMusic:
        return 'YouTube Music';
      case MusicPlatform.tidal:
        return 'Tidal';
      default:
        return 'Unknown';
    }
  }

  String _getContentTypeName(ContentType type) {
    switch (type) {
      case ContentType.track:
        return 'Track';
      case ContentType.album:
        return 'Album';
      default:
        return 'Unknown';
    }
  }

  String _getPlatformLogo(MusicPlatform platform) {
    switch (platform) {
      case MusicPlatform.spotify:
        return 'assets/images/platforms/spotify.png';
      case MusicPlatform.deezer:
        return 'assets/images/platforms/deezer.png';
      case MusicPlatform.appleMusic:
        return 'assets/images/platforms/apple_music.png';
      case MusicPlatform.youtubeMusic:
        return 'assets/images/platforms/youtube_music.png';
      case MusicPlatform.tidal:
        return 'assets/images/platforms/tidal.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Sharity')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Share your music between all platforms',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: _linkController,
              onChanged: _validateLink,
              decoration: InputDecoration(
                hintText: 'Paste your music link here...',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: _isValidLink
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 20),

            if (_detectedPlatform != null && _isValidLink)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _getPlatformLogo(_detectedPlatform!),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getPlatformName(_detectedPlatform!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getContentTypeName(
                              LinkValidator.detectContentType(_linkController.text),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            if (!_isValidLink && _linkController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Link not recognized. Supported: tracks and albums from Spotify, Deezer, Apple Music, YouTube Music, Tidal',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isValidLink
                  ? () {
                      final musicLink = MusicLink.fromUrl(_linkController.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ConversionPage(musicLink: musicLink),
                        ),
                      );
                    }
                  : null,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Convert', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
