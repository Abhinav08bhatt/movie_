class TmdbGenre {
  const TmdbGenre(this.id, this.name, this.color);

  final int id;
  final String name;
  final int color;
}

/// Common TMDB movie genres. Colors are for the spectrum / chips later.
const List<TmdbGenre> kTmdbGenres = [
  TmdbGenre(28, 'action', 0xFFFF8A3D),
  TmdbGenre(12, 'adventure', 0xFFE2F163),
  TmdbGenre(16, 'animation', 0xFF7D5FFF),
  TmdbGenre(35, 'comedy', 0xFFE2F163),
  TmdbGenre(80, 'crime', 0xFF8B6B4A),
  TmdbGenre(18, 'drama', 0xFF5EC8C0),
  TmdbGenre(14, 'fantasy', 0xFFE85D8C),
  TmdbGenre(27, 'horror', 0xFFB33A3A),
  TmdbGenre(10402, 'music', 0xFF7D5FFF),
  TmdbGenre(9648, 'mystery', 0xFF5E6BC8),
  TmdbGenre(10749, 'romance', 0xFFE85D8C),
  TmdbGenre(878, 'sci-fi', 0xFF5EC8F0),
  TmdbGenre(53, 'thriller', 0xFF9AA0A6),
  TmdbGenre(10752, 'war', 0xFF6B5B3A),
  TmdbGenre(37, 'western', 0xFFC4A35A),
];

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.voteAverage,
    required this.genres,
    this.posterPath,
    this.logoPath,
    this.releaseDate,
  });

  final int id;
  final String title;
  final String overview;
  final double voteAverage;
  final List<String> genres;
  final String? posterPath;
  final String? logoPath;
  final String? releaseDate;

  static const _imageBase = 'https://image.tmdb.org/t/p';

  /// Card + blurred vibe background. w500 is enough on a phone.
  String? get posterUrl =>
      posterPath == null ? null : '$_imageBase/w500$posterPath';

  /// Search / library thumbs.
  String? get thumbUrl =>
      posterPath == null ? null : '$_imageBase/w185$posterPath';

  String? get logoUrl =>
      logoPath == null ? null : '$_imageBase/w300$logoPath';

  String get year {
    final date = releaseDate;
    if (date == null || date.length < 4) return '—';
    return date.substring(0, 4);
  }

  String get ratingLabel => voteAverage.toStringAsFixed(1);

  factory Movie.fromTmdb(Map<String, dynamic> json) {
    final genreNames = <String>[];
    final genresRaw = json['genres'];
    if (genresRaw is List) {
      for (final item in genresRaw) {
        if (item is Map && item['name'] is String) {
          genreNames.add((item['name'] as String).toLowerCase());
        }
      }
    }
    if (genreNames.isEmpty) {
      final ids = json['genre_ids'];
      if (ids is List) {
        for (final id in ids) {
          final match = kTmdbGenres.where((g) => g.id == id);
          if (match.isNotEmpty) genreNames.add(match.first.name);
        }
      }
    }

    return Movie(
      id: (json['id'] as num).toInt(),
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : (json['name'] as String? ?? 'Untitled'),
      overview: (json['overview'] as String?) ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genres: genreNames,
      posterPath: json['poster_path'] as String?,
      logoPath: _pickLogo(json),
      releaseDate: json['release_date'] as String?,
    );
  }

  static String? _pickLogo(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is! Map) return null;
    final logos = images['logos'];
    if (logos is! List || logos.isEmpty) return null;

    final maps = logos.whereType<Map>().toList();
    if (maps.isEmpty) return null;

    Map picked = maps.first;
    for (final logo in maps) {
      if (logo['iso_639_1'] == 'en') {
        picked = logo;
        break;
      }
    }
    return picked['file_path'] as String?;
  }
}

class GenreStack {
  const GenreStack({required this.genre, required this.movies});

  final TmdbGenre genre;
  final List<Movie> movies;
}
