# Contributing to Music Sharity

Thank you for considering contributing to Music Sharity! This project is open-source under GPL v3, and contributions are welcome.

## Code of Conduct

Be respectful, constructive, and keep discussions on-topic.

## What We Need

### High Priority

- **iOS/macOS support** - Testing, TestFlight builds, App Store submission (requires Mac + Xcode)
- **Linux packaging** - AppImage, Snap, Flatpak
- **New platforms** - Amazon Music, SoundCloud, Pandora, etc.

### Always Welcome

- Bug fixes
- Various optimizations
- Translations / i18n
- Documentation improvements

## Development

**Requirements:** Flutter 3.38+, Dart 3.10+

```bash
git clone https://github.com/byteroast/music-sharity.git
cd music-sharity
flutter pub get
flutter run
```

### Project Structure

```
lib/
├── main.dart          # Entry point
├── models/            # Data models
├── pages/             # UI screens
├── services/          # API services, business logic
├── utils/             # Utility functions
├── widgets/           # Reusable widgets
└── theme/             # App theming
```

## Pull Requests

### Target Branch

All PRs should target the `dev/main` branch.

### Branch Naming

- `feature/description` for new features
- `fix/description` for bug fixes

### Before Submitting

```bash
dart format .
flutter analyze
```

### Commit Messages

Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`

Example: `feat: add Amazon Music platform support`

### PR Description

Include what you changed, why, and how you tested it. Add screenshots for UI changes.

## Coding Style

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart). Key points:

- Meaningful names, small focused functions
- Proper error handling and null safety
- Comments explain *why*, not *what*
- Prefer `async/await` over `.then()` chains

## Bug Reports

Check existing issues first. Include:

- Steps to reproduce
- Expected vs actual behavior
- Environment (OS, app version, device)
- Screenshots if relevant

## Feature Requests

Before submitting, check if it aligns with the project's privacy-first goals and would benefit most users.

## Recognition

Contributors are acknowledged in the README and release notes.

## Questions?

Open an issue or start a discussion on GitHub.
