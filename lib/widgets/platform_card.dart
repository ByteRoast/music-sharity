import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/link_validator.dart';

class PlatformCard extends StatelessWidget {
  final MusicPlatform platform;
  final VoidCallback onTap;

  const PlatformCard({
    super.key,
    required this.platform,
    required this.onTap,
  });

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
