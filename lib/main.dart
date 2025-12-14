import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'pages/home_page.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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

  bool get _isMobilePlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    if (_isMobilePlatform) {
      _initSharingIntent();
    }
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
