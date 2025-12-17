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
class TrackMetadata {
  final String title;
  final String artist;
  final String? album;
  final String? imageUrl;

  TrackMetadata({
    required this.title,
    required this.artist,
    this.album,
    this.imageUrl,
  });

  @override
  String toString() {
    return '$title - $artist${album != null ? ' ($album)' : ''}';
  }
}
