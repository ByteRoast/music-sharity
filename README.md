# Music Sharity

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-brightgreen)]()
[![Version](https://img.shields.io/badge/Version-1.0.0-blue)]()
[![GitHub issues](https://img.shields.io/github/issues/byteroast/music-sharity)](https://github.com/byteroast/music-sharity/issues)
[![GitHub stars](https://img.shields.io/github/stars/byteroast/music-sharity?style=social)](https://github.com/byteroast/music-sharity/stargazers)

> [!WARNING]
> Currently only **Android** and **Windows** builds are officially released and supported.
> 
> iOS, macOS, Linux, and Web builds are technically functional but not actively maintained due to hardware limitations (no Mac ownership). Community contributions for these platforms are welcome!

**Music Sharity** is a cross-platform app that converts music links between different streaming services instantly.

## Screenshots

<p align="center">
  <img src="./docs/assets/home_page.png" width="30%" />
  <img src="./docs/assets/conversion_page.png" width="30%" />
  <img src="./docs/assets/conversion_success.png" width="30%" />
</p>

## Features

- 🎵 **Convert between 5 platforms**: Spotify, Deezer, Apple Music, YouTube Music, Tidal
- 📀 **Supports tracks and albums**
- 🔄 **Fast conversion**: Direct API integration for Spotify/Deezer
- 📱 **Native Android sharing**: Appears in the share menu
- 🎨 **Modern Material Design 3** dark theme
- 🔒 **Privacy-focused**: No data collection, no tracking
- 🆓 **Free and Open Source** (GPL v3)

## Installation

### Android

**Option 1: Google Play Store** (Recommended)
```
[Coming soon - Link to Play Store]
```

**Option 2: Direct APK Download**
1. Go to [Releases](https://github.com/byteroast/music-sharity/releases)
2. Download the latest `music-sharity-x.y.z.apk`
3. Enable "Install from unknown sources" in Settings
4. Install the APK

### Windows

1. Go to [Releases](https://github.com/byteroast/music-sharity/releases)
2. Download `music-sharity-windows-x.y.z.zip`
3. Extract and run `music_sharity.exe`

### Other Platforms

While **iOS, macOS, Linux, and Web** builds can be compiled, they are **not officially supported** at this time due to:
- Lack of hardware for testing (no Mac)
- Limited platform-specific optimizations
- No active maintenance

**Community contributions are welcome!** If you have the hardware and want to help maintain these platforms, please open an issue or PR.

## How to Use

### Method 1: Share from Music App (Android only)

1. Open Spotify, Deezer, or any supported music app
2. Find a track or album you want to share
3. Tap the **Share** button
4. Select **Music Sharity** from the share menu
5. Choose your destination platform
6. Share the converted link!

### Method 2: Manual Link Conversion

1. Open **Music Sharity**
2. Paste your music link in the text field
3. Click **Convert**
4. Select your destination platform
5. Share or copy the converted link

## Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| **Spotify** | ✅ Fully supported | Direct API integration |
| **Deezer** | ✅ Fully supported | Direct API integration |
| **Apple Music** | ✅ Supported | Via Odesli API |
| **YouTube Music** | ✅ Supported | Via Odesli API |
| **Tidal** | ✅ Supported | Via Odesli API |

## Technical Details

**Built with:**
- [Flutter](https://flutter.dev) - Cross-platform framework
- Material Design 3 - Modern UI design
- Spotify API - Direct track metadata
- Deezer API - Direct track metadata
- [Odesli/song.link](https://odesli.co) - Universal link conversion

**Architecture:**
- Direct API calls for Spotify ↔ Deezer (fast, with metadata)
- Odesli API for other platforms (universal compatibility)
- No user data collection
- No tracking or analytics

## Privacy

Music Sharity **does not collect or store any personal data**.

- ✅ No user accounts
- ✅ No tracking
- ✅ No analytics
- ✅ No ads
- ✅ All conversions happen in real-time

Read our [Privacy Policy](https://byteroast.github.io/music-sharity/PRIVACY) for details.

## Build from Source

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+)
- Android Studio or VS Code
- Spotify Developer Account (for API keys)

### Setup

1. **Clone the repository:**
```bash
git clone https://github.com/byteroast/music-sharity.git
cd music-sharity
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Create `.env` file:**
```env
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
```
   Get your Spotify credentials at [developer.spotify.com](https://developer.spotify.com/dashboard)

4. **Run the app:**
```bash
# Android
flutter run

# Windows
flutter run -d windows

# Web (experimental)
flutter run -d chrome
```

5. **Build release:**
```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release
```

## Contributing

Contributions are welcome! Especially for:

- 🍎 **iOS/macOS support** (need Mac owners!)
- 🌐 **Web optimization**
- 🎵 **New platform integrations**
- 🐛 **Bug fixes**

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE) file for details.

This means:
- ✅ You can use, modify, and distribute this software
- ✅ You must keep the same license (GPL v3)
- ✅ You must disclose the source code
- ✅ Changes must be documented

## Author

**Sikelio (Byte Roast)**

- GitHub: [@sikelio](https://github.com/sikelio)

## Acknowledgments

- [Flutter](https://flutter.dev) - Amazing cross-platform framework
- [Spotify API](https://developer.spotify.com) - Track metadata
- [Deezer API](https://developers.deezer.com) - Track metadata
- [Odesli](https://odesli.co) - Universal music link conversion
- All contributors and testers!

## Support

If you find this project useful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 🤝 Contributing code
