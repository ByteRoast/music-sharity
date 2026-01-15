# Music Sharity

[![Version](https://img.shields.io/badge/Version-1.0.0-blue)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![GitHub issues](https://img.shields.io/github/issues/byteroast/music-sharity)](https://github.com/byteroast/music-sharity/issues)
[![Build Tests](https://github.com/ByteRoast/music-sharity/actions/workflows/build_tests.yml/badge.svg)](https://github.com/ByteRoast/music-sharity/actions/workflows/build_tests.yml)
[![Platform](https://img.shields.io/badge/Platform-Android%20|%20Windows%20|%20Linux%20|%20Web-brightgreen)]()

[![GitHub stars](https://img.shields.io/github/stars/byteroast/music-sharity?style=social)](https://github.com/byteroast/music-sharity/stargazers)

> [!WARNING]
> Currently only **Android**, **Windows**, **Linux** and **Web** builds are officially released and supported.
> 
> iOS and macOS builds are technically functional but not actively maintained due to hardware limitations (no Mac ownership). Community contributions for these platforms are welcome!

**Music Sharity** is a cross-platform app that converts music links between different streaming services instantly.

## Screenshots

<p align="center">
  <img src="./docs/assets/home-page.png" width="30%" />
  <img src="./docs/assets/conversion-page.png" width="30%" />
  <img src="./docs/assets/conversion-success.png" width="30%" />
</p>

## Features

- **Convert between 5 platforms**: Spotify, Deezer, Apple Music, YouTube Music, Tidal
- **Supports tracks and albums**
- **Fast conversion**: Powered by Odesli API
- **Native Android sharing**: Appears in the share menu
- **Privacy-focused**: No API keys, no data collection, no tracking

## Installation

### Android

**Option 1: Google Play Store** (Recommended)
```
[Coming soon - Link to Play Store]
```

**Option 2: Direct APK Download**
1. Go to [Releases](https://github.com/byteroast/music-sharity/releases)
2. Download the latest `music-sharity-x.y.z+<build>.apk`
3. Enable "Install from unknown sources" in Settings
4. Install the APK

### Windows

1. Go to [Releases](https://github.com/byteroast/music-sharity/releases)
2. Download `music-sharity-x.y.z+<build>-windows-x64.msi`
3. Install the program
4. Run `Music Sharity`

### Linux

1. Go to [Releases](https://github.com/byteroast/music-sharity/releases)
2. Download `music-sharity-x.y.z+<build>-amd64.deb` or `music-sharity-x.y.z-<build>-x86_64.rpm`
3. Install the package
4. Run `Music Sharity`

### Web

1. Go to [https://music-sharity.byteroast.fr](https://music-sharity.byteroast.fr)
2. Use it like this or install it as PWA (On Android devices the PWA can appear in the share fleet)

### Other Platforms

While **iOS and macOS** builds can be compiled, they are **not officially supported** at this time due to:
- Lack of hardware for testing (no Mac)
- No active maintenance

**Community contributions are welcome!** If you have the hardware and want to help maintain these platforms, please open an issue or PR.

## How to Use

### Method 1: Share from Music App (Android or Android PWA only)

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

| Platform | Status |
|----------|--------|
| **Spotify** | Fully supported |
| **Deezer** | Fully supported |
| **Apple Music** | Fully supported |
| **YouTube Music** | Fully supported |
| **Tidal** | Fully supported |

## Technical Details

**Built with:**
- [Flutter](https://flutter.dev) - Cross-platform framework
- Material Design 3 - Modern UI design
- [Odesli/song.link](https://odesli.co) - Universal link conversion API
- [Cloudflare Workers](https://workers.cloudflare.com) - Privacy-first CORS proxy (web version only)

**Architecture:**
- **Native apps** (Android, iOS, Windows, macOS, Linux): Direct API calls to Odesli (zero intermediaries)
- **Web app**: Privacy-first CORS proxy via Cloudflare Workers (zero logging, zero tracking)
- No API keys required - fully open source friendly
- No user data collection
- No tracking or analytics
- Proxy source code: [music-sharity-proxy](https://github.com/ByteRoast/music-sharity-proxy)

**Privacy infrastructure:**
- Native apps: Direct API communication ✅
- Web app: Stateless edge proxy with no data retention ✅
- All code is open source and auditable ✅

> [!NOTE]
> Due to Odesli API restrictions, the application is limited to **10 requests per minute**. A rate limiting mechanism is implemented to ensure smooth operation within this constraint.

## Privacy

Music Sharity **does not collect or store any personal data**.

- No user accounts
- No tracking
- No analytics
- No ads
- All conversions happen in real-time via Odesli

Read our [Privacy Policy](https://music-sharity.byteroast.fr/PRIVACY) for details.

## Build from Source

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+)
- Android Studio or VS Code

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

3. **Run the app:**
```bash
# Android
flutter run

# Windows
flutter run -d windows

# Linux
flutter run -d linux

# Web
flutter run -d chrome
```

4. **Build release:**
```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# Web
flutter build web --release
```

## Contributing

Contributions are welcome! Especially for:

- **iOS/macOS support** (need Mac owners!)
- **Web optimizations**
- **New platform integrations**
- **Bug fixes**

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE](LICENSE.md) file for details.

This means:
- You can use, modify, and distribute this software
- You must keep the same license (GPL v3)
- You must disclose the source code
- Changes must be documented

## Author

**Sikelio (Byte Roast)**

- GitHub: [@sikelio](https://github.com/sikelio)

## Acknowledgments

- [Flutter](https://flutter.dev) - Amazing cross-platform framework
- [Odesli](https://odesli.co) - Universal music link conversion API
- All contributors and testers!

## Support

If you find this project useful, please consider:
- Starring the repository
- Reporting bugs
- Suggesting features
- Contributing code
