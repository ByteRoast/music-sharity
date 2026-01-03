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
import 'package:flutter/material.dart';
import 'about_page.dart';
import 'conversion_page.dart';
import '../models/music_link.dart';
import '../utils/link_validator.dart';
import '../utils/ui_helpers.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Sharity'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            Center(
              child: Image.asset(
                'assets/images/brandings/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Share music across all platforms',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            TextField(
              controller: _linkController,
              onChanged: _validateLink,
              decoration: InputDecoration(
                hintText: 'Paste your music link here...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                  child: const Icon(Icons.link),
                ),
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
                          UiHelpers.getPlatformLogo(_detectedPlatform!),
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
                            UiHelpers.getPlatformName(_detectedPlatform!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            UiHelpers.getContentTypeName(
                              LinkValidator.detectContentType(
                                _linkController.text,
                              ),
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
