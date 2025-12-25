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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:app_links/app_links.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';
import 'utils/web_share_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MusicSharityApp());
}

class MusicSharityApp extends StatefulWidget {
  const MusicSharityApp({super.key});

  @override
  State<MusicSharityApp> createState() => _MusicSharityAppState();
}

class _MusicSharityAppState extends State<MusicSharityApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSubscription;
  StreamSubscription<List<SharedMediaFile>>? _sharingMediaSubscription;
  String? _sharedLink;
  Timer? _webShareCheckTimer;

  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _initWebSharing();
      _startWebSharePolling();
    } else {
      _initDeepLinks();

      if (_isMobilePlatform) {
        _initSharingIntent();
      }
    }
  }

  void _initWebSharing() {
    final sharedUrl = WebShareHandler.getSharedUrl();

    if (sharedUrl != null && sharedUrl.isNotEmpty) {
      setState(() {
        _sharedLink = sharedUrl;
      });

      debugPrint('Web share detected: $_sharedLink');
    }
  }

  void _startWebSharePolling() {
    int checkCount = 0;

    _webShareCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkCount++;
      
      final sharedUrl = WebShareHandler.getSharedUrl();
      if (sharedUrl != null && sharedUrl.isNotEmpty && sharedUrl != _sharedLink) {
        debugPrint('Web share detected via polling: $sharedUrl');

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

  Future<void> _initSharingIntent() async {
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> value,
    ) {
      if (value.isNotEmpty) {
        final sharedText = value.first.path;
        if (sharedText.isNotEmpty) {
          setState(() {
            _sharedLink = sharedText;
          });
        }
      }
    });

    _sharingMediaSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedMediaFile> value) {
            if (value.isNotEmpty) {
              final sharedText = value.first.path;
              if (sharedText.isNotEmpty) {
                setState(() {
                  _sharedLink = sharedText;
                });
              }
            }
          },
          onError: (err) {
            debugPrint('Error receiving shared media: $err');
          },
        );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _sharingMediaSubscription?.cancel();
    _webShareCheckTimer?.cancel();

    if (_isMobilePlatform) {
      ReceiveSharingIntent.instance.reset();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Sharity',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(initialLink: _sharedLink, key: ValueKey(_sharedLink)),
    );
  }
}
