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
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/music_link.dart';
import '../utils/link_validator.dart';
import '../widgets/platform_card.dart';
import '../services/music_converter_service.dart';
import '../pages/home_page.dart';

class ConversionPage extends StatefulWidget {
  final MusicLink musicLink;

  const ConversionPage({super.key, required this.musicLink});

  @override
  State<ConversionPage> createState() => _ConversionPageState();
}

class _ConversionPageState extends State<ConversionPage> {
  final MusicConverterService _converterService = MusicConverterService();

  List<MusicPlatform> get availablePlatforms {
    return MusicPlatform.values
        .where(
          (platform) =>
              platform != widget.musicLink.sourcePlatform &&
              platform != MusicPlatform.unknown,
        )
        .toList();
  }

  String get sourcePlatformName {
    switch (widget.musicLink.sourcePlatform) {
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

  Future<void> _convertToPlatform(
    BuildContext context,
    MusicPlatform targetPlatform,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _converterService.convert(
        widget.musicLink,
        targetPlatform,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        _showConversionSuccessDialog(result, targetPlatform);
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Conversion failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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

  IconData _getContentIcon(ContentType type) {
    switch (type) {
      case ContentType.track:
        return Icons.music_note;
      case ContentType.album:
        return Icons.album;
      default:
        return Icons.music_note;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose destination platform')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Source',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _getContentIcon(widget.musicLink.contentType),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sourcePlatformName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getContentTypeName(widget.musicLink.contentType),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Convert to',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: availablePlatforms.length,
                itemBuilder: (context, index) {
                  final platform = availablePlatforms[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: PlatformCard(
                      platform: platform,
                      onTap: () => _convertToPlatform(context, platform),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversionSuccessDialog(
    ConversionResult result,
    MusicPlatform targetPlatform,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conversion successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.metadata != null) ...[
              Text(
                result.metadata!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(result.metadata!.artist),
              const SizedBox(height: 16),
            ],
            Text('Converted to ${_getPlatformName(targetPlatform)}'),
            const SizedBox(height: 8),
            SelectableText(
              result.url!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _shareLink(result);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareLink(ConversionResult result) async {
    if (result.url == null) return;

    try {
      await SharePlus.instance.share(ShareParams(text: result.url));
      
      if (!mounted) return;
      
      // Retour à une HomePage fraîche
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
      
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
