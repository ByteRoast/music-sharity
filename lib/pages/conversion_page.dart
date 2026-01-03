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
import 'package:share_plus/share_plus.dart';
import '../models/music_link.dart';
import '../utils/link_validator.dart';
import '../utils/ui_helpers.dart';
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
  bool _isConverting = false;

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
    if (_isConverting) return;

    setState(() {
      _isConverting = true;
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await _converterService.convert(
        widget.musicLink,
        targetPlatform,
      );

      if (!mounted) return;

      setState(() {
        _isConverting = false;
      });

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

      setState(() {
        _isConverting = false;
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose destination platform')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Source',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            UiHelpers.getPlatformLogo(
                              widget.musicLink.sourcePlatform,
                            ),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sourcePlatformName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    UiHelpers.getContentIcon(
                                      widget.musicLink.contentType,
                                    ),
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    UiHelpers.getContentTypeName(
                                      widget.musicLink.contentType,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                  child: AbsorbPointer(
                    absorbing: _isConverting,
                    child: Opacity(
                      opacity: _isConverting ? 0.5 : 1.0,
                      child: ListView.builder(
                        itemCount: availablePlatforms.length,
                        itemBuilder: (context, index) {
                          final platform = availablePlatforms[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: PlatformCard(
                              platform: platform,
                              onTap: () =>
                                  _convertToPlatform(context, platform),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isConverting)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Converting...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
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
            Text('Converted to ${UiHelpers.getPlatformName(targetPlatform)}'),
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
