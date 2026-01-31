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
import 'dart:async';
import 'dart:io' show Platform;
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/conversion_history_entry.dart';
import 'models/music_platform.dart';
import 'models/track_metadata.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'utils/web_share_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await Hive.initFlutter();

  Hive.registerAdapter(ConversionHistoryEntryAdapter());
  Hive.registerAdapter(MusicPlatformAdapter());
  Hive.registerAdapter(TrackMetadataAdapter());

  await Hive.openBox<ConversionHistoryEntry>('conversion_history');

  runApp(const MusicSharityApp());
}

class MusicSharityApp extends StatefulWidget {
  const MusicSharityApp({super.key});

  @override
  State<MusicSharityApp> createState() => _MusicSharityAppState();
}

class _MusicSharityAppState extends State<MusicSharityApp> {
  static const EventChannel _shareChannel = EventChannel(
    'fr.byteroast.music_sharity/share',
  );

  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _deepLinkSubscription;
  StreamSubscription<Object?>? _nativeShareSubscription;
  String? _sharedLink;
  Timer? _webShareCheckTimer;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _initWebSharing();
      _startWebSharePolling();
    } else {
      _initDeepLinks();

      if (Platform.isAndroid) {
        _initNativeSharing();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Sharity',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: MainScreen(initialLink: _sharedLink),
    );
  }

  void _initWebSharing() {
    final sharedUrl = WebShareHandler.getSharedUrl();

    if (sharedUrl != null && sharedUrl.isNotEmpty) {
      setState(() {
        _sharedLink = sharedUrl;
      });
    }
  }

  void _startWebSharePolling() {
    int checkCount = 0;

    _webShareCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkCount++;

      final sharedUrl = WebShareHandler.getSharedUrl();
      if (sharedUrl != null &&
          sharedUrl.isNotEmpty &&
          sharedUrl != _sharedLink) {
        setState(() {
          _sharedLink = sharedUrl;
        });

        timer.cancel();
      }

      if (checkCount >= 10) {
        timer.cancel();
      }
    });
  }

  Future<void> _initDeepLinks() async {
    try {
      final uri = await _appLinks.getInitialLink();

      if (uri != null) {
        setState(() {
          _sharedLink = uri.toString();
        });
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        setState(() {
          _sharedLink = uri.toString();
        });
      },
      onError: (err) {
        debugPrint('Error receiving link: $err');
      },
    );
  }

  void _initNativeSharing() {
    _nativeShareSubscription = _shareChannel.receiveBroadcastStream().listen(
      (url) {
        debugPrint('Native share received: $url');

        if (url is String && url.isNotEmpty) {
          setState(() {
            _sharedLink = url;
          });
        }
      },
      onError: (err) {
        debugPrint('Error receiving native share: $err');
      },
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _nativeShareSubscription?.cancel();
    _webShareCheckTimer?.cancel();

    super.dispose();
  }
}
