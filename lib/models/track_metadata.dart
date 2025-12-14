class TrackMetadata {
  final String title;
  final String artist;
  final String? album;
  final String? isrc;
  final String? imageUrl;
  final int? durationMs;

  TrackMetadata({
    required this.title,
    required this.artist,
    this.album,
    this.isrc,
    this.imageUrl,
    this.durationMs,
  });

  factory TrackMetadata.fromJson(Map<String, dynamic> json, String source) {
    switch (source) {
      case 'spotify':
        return TrackMetadata._fromSpotify(json);
      case 'deezer':
        return TrackMetadata._fromDeezer(json);
      default:
        throw Exception('Unsupported source: $source');
    }
  }

  factory TrackMetadata._fromSpotify(Map<String, dynamic> json) {
    return TrackMetadata(
      title: json['name'] ?? '',
      artist: (json['artists'] as List?)
        ?.map((a) => a['name'] as String)
        .join(', ') ?? '',
      album: json['album']?['name'],
      isrc: json['external_ids']?['isrc'],
      imageUrl: (json['album']?['images'] as List?)?.first?['url'],
      durationMs: json['duration_ms'],
    );
  }
  factory TrackMetadata._fromDeezer(Map<String, dynamic> json) {
    return TrackMetadata(
      title: json['title'] ?? '',
      artist: json['artist']?['name'] ?? '',
      album: json['album']?['title'],
      isrc: json['isrc'],
      imageUrl: json['album']?['cover_xl'],
      durationMs: (json['duration'] as int?) != null 
        ? (json['duration'] as int) * 1000 
        : null,
    );
  }

  @override
  String toString() {
    return '$title - $artist${album != null ? ' ($album)' : ''}';
  }
}
