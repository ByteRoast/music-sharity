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
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

String? getSharedUrlImpl() {
  try {
    final uri = Uri.parse(web.window.location.href);

    if (uri.path == '/share' || uri.path == '/share/') {
      final sharedUrl = uri.queryParameters['url'];
      final sharedText = uri.queryParameters['text'];

      String? musicUrl;

      if (sharedUrl != null && sharedUrl.isNotEmpty) {
        musicUrl = sharedUrl;
      } else if (sharedText != null && sharedText.isNotEmpty) {
        final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

        final match = urlPattern.firstMatch(sharedText);

        musicUrl = match?.group(0);
      }

      if (musicUrl != null && musicUrl.isNotEmpty) {
        final newUrl = '/#shared=${Uri.encodeComponent(musicUrl)}';

        web.window.history.replaceState(null, '', newUrl);

        return musicUrl;
      } else {
        web.window.history.replaceState(null, '', '/');
      }
    }

    if (uri.fragment.isNotEmpty) {
      final fragment = uri.fragment;

      if (fragment.startsWith('shared=')) {
        final encodedUrl = fragment.substring('shared='.length);
        final sharedUrl = Uri.decodeComponent(encodedUrl);

        web.window.history.replaceState(null, '', '/');

        return sharedUrl;
      }
    }
  } catch (e) {
    debugPrint('WebShareHandler - Error: $e');
  }

  return null;
}
