import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/movie.dart';
import '../tmdb/tmdb_service.dart';

class MovieSession extends ChangeNotifier {
  MovieSession({required this.tmdb});

  final TmdbService tmdb;

  List<Movie> _stack = [];
  int _index = 0;
  TmdbGenre? genre;
  bool exploring = false;
  String? error;

  final List<Movie> wishlist = [];
  final List<Movie> watched = [];
  final List<Movie> downloaded = [];

  Movie? get current {
    if (_index >= _stack.length) return null;
    return _stack[_index];
  }

  int get remaining {
    final left = _stack.length - _index;
    return left < 0 ? 0 : left;
  }

  Future<void> explore(BuildContext context) async {
    exploring = true;
    error = null;
    notifyListeners();
    try {
      final pulled = await tmdb.pullRandomGenreStack();
      if (!context.mounted) return;
      await _precache(context, pulled.movies);
      if (!context.mounted) return;
      _stack = pulled.movies;
      _index = 0;
      genre = pulled.genre;
    } catch (e) {
      error = e is TmdbException ? e.message : 'could not load movies';
    } finally {
      exploring = false;
      notifyListeners();
    }
  }

  void pass() {
    if (current == null) return;
    _index += 1;
    notifyListeners();
  }

  void addCurrentToWishlist() {
    final movie = current;
    if (movie == null) return;
    if (!wishlist.any((m) => m.id == movie.id)) {
      wishlist.add(movie);
    }
    _index += 1;
    notifyListeners();
  }

  Future<Movie> openFromSearch(BuildContext context, Movie preview) async {
    final movie = await tmdb.hydrate(preview.id);
    if (context.mounted) {
      await _precache(context, [movie]);
    }
    return movie;
  }

  Future<void> _precache(BuildContext context, List<Movie> movies) async {
    await Future.wait(
      movies.map((movie) async {
        final poster = movie.posterUrl;
        if (poster != null && context.mounted) {
          try {
            await precacheImage(CachedNetworkImageProvider(poster), context);
          } catch (_) {}
        }
        final logo = movie.logoUrl;
        if (logo != null && context.mounted) {
          try {
            await precacheImage(CachedNetworkImageProvider(logo), context);
          } catch (_) {}
        }
      }),
    );
  }
}

class MovieSessionScope extends InheritedNotifier<MovieSession> {
  const MovieSessionScope({
    super.key,
    required MovieSession session,
    required super.child,
  }) : super(notifier: session);

  static MovieSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MovieSessionScope>();
    assert(scope != null, 'MovieSessionScope not found');
    return scope!.notifier!;
  }
}
