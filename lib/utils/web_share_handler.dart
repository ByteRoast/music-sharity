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
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

class WebShareHandler {
  static String? getSharedUrl() {
    if (kIsWeb) {
      final uri = Uri.parse(web.window.location.href);

      debugPrint('WebShareHandler - Current URL: ${uri.toString()}');
      debugPrint('WebShareHandler - Path: ${uri.path}');
      debugPrint('WebShareHandler - Query params: ${uri.queryParameters}');

      if (uri.path == '/share' || uri.path == '/share/') {
        final sharedUrl = uri.queryParameters['url'];
        final sharedText = uri.queryParameters['text'];

        debugPrint('WebShareHandler - Shared URL detected: $sharedUrl');
        debugPrint('WebShareHandler - Shared text detected: $sharedText');

        web.window.history.replaceState(null, '', '/');

        return sharedUrl ?? sharedText;
      }
    }

    return null;
  }
}
