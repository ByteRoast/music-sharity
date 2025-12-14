# Contributing to Music Sharity

First off, thank you for considering contributing to Music Sharity!

Music Sharity is an open-source project, and we welcome contributions from everyone. Whether you're fixing bugs, adding features, improving documentation, or helping with platform support, your help is appreciated!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Guidelines](#coding-guidelines)
- [Platform-Specific Contributions](#platform-specific-contributions)

## Code of Conduct

This project adheres to a simple code of conduct:
- Be respectful and inclusive
- Focus on constructive criticism
- Help others learn and grow
- Keep discussions on-topic

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**When reporting a bug, include:**
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Screenshots (if applicable)
- Your environment:
  - OS and version (Android 14, Windows 11, etc.)
  - App version
  - Device model (for mobile)

**Bug report template:**
```markdown
**Description**
A clear description of the bug.

**Steps to Reproduce**
1. Open app
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: Android 14
- App Version: 1.0.0
- Device: Pixel 7

**Screenshots**
If applicable, add screenshots.
```

### Suggesting Features

We welcome feature suggestions! Before creating a feature request:
- Check if it's already been suggested
- Make sure it aligns with the project's goals
- Consider if it would benefit most users

**Feature request template:**
```markdown
**Feature Description**
A clear description of the feature.

**Use Case**
Why is this feature needed? Who would benefit?

**Proposed Solution**
How would you implement this?

**Alternatives**
Any alternative solutions you've considered?
```

### Contributing Code

We especially welcome contributions for:

- **iOS/macOS support** - If you own a Mac and can test/maintain these platforms
- **Linux packaging** - AppImage, Snap, Flatpak
- **Web optimization** - Improve web platform support
- **New platforms** - Amazon Music, SoundCloud, Pandora, etc.
- **Translations** - Internationalization support
- **Bug fixes**
- **Documentation** - Improve README, comments, guides

## Development Setup

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10 or higher)
- [Git](https://git-scm.com/)
- IDE: [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- Spotify Developer Account (for API keys)

### Setup Steps

1. **Fork the repository**
   - Click the "Fork" button at the top of this repository

2. **Clone your fork**
```bash
git clone https://github.com/YOUR_USERNAME/music-sharity.git
cd music-sharity
```

3. **Add upstream remote**
```bash
git remote add upstream https://github.com/byteroast/music-sharity.git
```

4. **Install dependencies**
```bash
flutter pub get
```

5. **Create `.env` file** (in project root)
```env
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
```
   
Get credentials at [developer.spotify.com/dashboard](https://developer.spotify.com/dashboard)

6. **Run the app**
```bash
   # Android emulator/device
   flutter run
   
   # Windows
   flutter run -d windows
   
   # Chrome (web)
   flutter run -d chrome
```

7. **Verify everything works**
   - Test link conversion (Spotify → Deezer, etc.)
   - Test sharing (Android only)
   - Check UI on different screen sizes

## Pull Request Process

1. **Create a new branch**
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

2. **Make your changes**
   - Follow the [Coding Guidelines](#coding-guidelines)
   - Write clear, descriptive commit messages
   - Add comments for complex logic

3. **Test your changes**
```bash
# Run the app and test manually
flutter run

# Format code
dart format .

# Analyze code
flutter analyze
```

4. **Commit your changes**
```bash
git add .
git commit -m "feat: add Amazon Music support"
```
   
   **Commit message format:**
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Code style/formatting
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

5. **Push to your fork**
```bash
git push origin feature/your-feature-name
```

6. **Create Pull Request**
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template
   - Submit!

### Pull Request Guidelines

- **Title**: Clear and descriptive (e.g., "Add Amazon Music platform support")
- **Description**: Explain what you changed and why
- **Screenshots**: Include before/after screenshots for UI changes
- **Testing**: Describe how you tested your changes
- **Breaking changes**: Clearly note any breaking changes

**PR template:**
```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Code refactoring

## Changes Made
- Added X
- Fixed Y
- Updated Z

## Testing
How did you test these changes?

## Screenshots (if applicable)
Before | After
```

## Coding Guidelines

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` to format code
- Run `flutter analyze` before committing
- Maximum line length: 80 characters (flexible for readability)

### Code Organization
```
lib/
├── main.dart              # App entry point
├── models/                # Data models
├── pages/                 # UI screens
├── services/              # API services, business logic
├── utils/                 # Utility functions
├── widgets/               # Reusable widgets
└── theme/                 # App theming
```

### Best Practices

- **Use meaningful names**: `convertMusicLink()` not `doThing()`
- **Keep functions small**: One function = one responsibility
- **Add comments**: Explain *why*, not *what*
- **Error handling**: Always handle potential errors
- **Null safety**: Use null-safe code
- **Async/await**: Prefer over `.then()` chains

### Example
```dart
// ❌ Bad
Future<String?> f(String u) async {
  var r = await http.get(Uri.parse(u));
  return jsonDecode(r.body)['id'];
}

// ✅ Good
/// Fetches track ID from Spotify API
/// 
/// Returns null if track not found or API error occurs
Future<String?> fetchSpotifyTrackId(String trackUrl) async {
  try {
    final response = await http.get(Uri.parse(trackUrl));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'] as String?;
    }
    
    return null;
  } catch (e) {
    debugPrint('Error fetching Spotify track: $e');
    return null;
  }
}
```

## 🖥️ Platform-Specific Contributions

### iOS/macOS (We need help!)

**Requirements:**
- Mac with macOS
- Xcode installed
- Apple Developer account (for testing on device)

**What we need:**
- Testing sharing functionality on iOS
- TestFlight builds
- App Store submission help
- macOS desktop app testing

**How to help:**
1. Build and test on iOS/macOS
2. Report iOS-specific bugs
3. Optimize for iOS Share Sheet
4. Help with App Store metadata

### Linux (We need packages!)

**What we need:**
- AppImage packaging
- Snap packaging
- Flatpak packaging
- Testing on different distros

### Web (Optimization needed!)

**What we need:**
- CORS proxy solution
- PWA optimization
- Mobile web responsiveness
- Performance improvements

## License

By contributing to Music Sharity, you agree that your contributions will be licensed under the **GNU General Public License v3.0**.

This means:
- Your code will remain open source
- Others can use, modify, and distribute it
- Any derivative work must also be GPL v3

## Recognition

All contributors will be recognized in:
- README.md acknowledgments section
- Release notes
- GitHub contributors page

## Questions?

- **Issues**: [GitHub Issues](https://github.com/byteroast/music-sharity/issues)
- **Discussions**: [GitHub Discussions](https://github.com/byteroast/music-sharity/discussions)

---

**Thank you for contributing to Music Sharity!**
