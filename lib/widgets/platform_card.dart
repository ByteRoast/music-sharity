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
import '../theme/app_theme.dart';
import '../utils/link_validator.dart';

class PlatformCard extends StatelessWidget {
  final MusicPlatform platform;
  final VoidCallback onTap;

  const PlatformCard({super.key, required this.platform, required this.onTap});

  String get platformName {
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

  String get platformLogo {
    switch (platform) {
      case MusicPlatform.spotify:
        return 'assets/images/platforms/spotify.png';
      case MusicPlatform.deezer:
        return 'assets/images/platforms/deezer.png';
      case MusicPlatform.appleMusic:
        return 'assets/images/platforms/apple-music.png';
      case MusicPlatform.youtubeMusic:
        return 'assets/images/platforms/youtube-music.png';
      case MusicPlatform.tidal:
        return 'assets/images/platforms/tidal.png';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  platformLogo,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  platformName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.lightGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
