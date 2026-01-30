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
import 'odesli_service.dart';
import '../models/music_link.dart';

class MusicConverterService {
  final OdesliService _odesliService = OdesliService();

  static final MusicConverterService _instance =
      MusicConverterService._internal();

  factory MusicConverterService() => _instance;

  MusicConverterService._internal();

  Future<OdesliResult> convert(MusicLink sourceLink) async {
    return await _odesliService.convertLink(sourceLink.originalUrl);
  }
}
