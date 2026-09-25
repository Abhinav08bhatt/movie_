import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config.dart';
import '../models/movie.dart';

class TmdbException implements Exception {
  TmdbException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? _createClient();

  final http.Client _client;
  final _random = Random();

  static const _host = 'api.themoviedb.org';
  static const _concurrency = 3;
  static const _maxAttempts = 5;

  static http.Client _createClient() {
    final inner = HttpClient()
      ..maxConnectionsPerHost = 4
      ..idleTimeout = const Duration(seconds: 8)
      ..connectionTimeout = const Duration(seconds: 12);
    return IOClient(inner);
  }

  Future<GenreStack> pullRandomGenreStack() async {
    _ensureKey();
    final shuffled = [...kTmdbGenres]..shuffle(_random);

    TmdbException? lastError;
    for (final genre in shuffled.take(3)) {
      try {
        final movies = await _discoverAndHydrate(genre);
        if (movies.length >= 5) {
          final take = min(movies.length, 8 + _random.nextInt(5)); // 8–12
          return GenreStack(
            genre: genre,
            movies: movies.take(take).toList(),
          );
        }
      } on TmdbException catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? TmdbException('could not load a genre stack');
  }

  Future<List<Movie>> search(String query) async {
    _ensureKey();
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final data = await _get('/3/search/movie', {
      'query': trimmed,
      'include_adult': 'false',
      'language': 'en-US',
      'page': '1',
    });
    final results = data['results'];
    if (results is! List) return const [];

    return results
        .whereType<Map>()
        .map((m) => Movie.fromTmdb(Map<String, dynamic>.from(m)))
        .where((m) => m.posterPath != null)
        .take(20)
        .toList();
  }

  Future<Movie> hydrate(int id) async {
    _ensureKey();
    final data = await _get('/3/movie/$id', {
      'language': 'en-US',
      'append_to_response': 'images',
      'include_image_language': 'en,null',
    });
    return Movie.fromTmdb(data);
  }

  Future<List<Movie>> _discoverAndHydrate(TmdbGenre genre) async {
    final page = 1 + _random.nextInt(4);
    final data = await _get('/3/discover/movie', {
      'with_genres': '${genre.id}',
      'language': 'en-US',
      'include_adult': 'false',
      'sort_by': 'popularity.desc',
      'vote_count.gte': '80',
      'page': '$page',
    });
    final results = data['results'];
    if (results is! List) return const [];

    final ids = results
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .where((m) => m['poster_path'] != null)
        .map((m) => (m['id'] as num).toInt())
        .take(12)
        .toList();

    final hydrated = <Movie>[];
    for (var i = 0; i < ids.length; i += _concurrency) {
      final chunk = ids.sublist(i, min(i + _concurrency, ids.length));
      final batch = await Future.wait(
        chunk.map((id) async {
          try {
            return await hydrate(id);
          } catch (_) {
            return null;
          }
        }),
      );
      hydrated.addAll(
        batch.whereType<Movie>().where((m) => m.posterPath != null),
      );
    }
    return hydrated;
  }

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> params,
  ) async {
    final uri = Uri.https(_host, path, {
      'api_key': kTmdbApiKey,
      ...params,
    });

    Object? lastError;
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(uri)
            .timeout(const Duration(seconds: 12));
        if (response.statusCode == 429) {
          await Future<void>.delayed(Duration(milliseconds: 500 * (attempt + 1)));
          continue;
        }
        if (response.statusCode != 200) {
          throw TmdbException('tmdb ${response.statusCode}');
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw TmdbException('bad tmdb payload');
        }
        return decoded;
      } on TmdbException {
        rethrow;
      } catch (e) {
        lastError = e;
        if (!_isRetryable(e) || attempt == _maxAttempts - 1) {
          throw TmdbException('could not reach tmdb');
        }
        await Future<void>.delayed(
          Duration(milliseconds: 220 * (attempt + 1) * (attempt + 1)),
        );
      }
    }
    throw TmdbException(lastError == null ? 'could not reach tmdb' : 'could not reach tmdb');
  }

  bool _isRetryable(Object error) {
    if (error is SocketException || error is HttpException) return true;
    if (error is http.ClientException) return true;
    final text = error.toString();
    return text.contains('Connection reset') ||
        text.contains('Connection closed') ||
        text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('timed out') ||
        text.contains('TimeoutException');
  }

  void _ensureKey() {
    if (kTmdbApiKey.isEmpty) {
      throw TmdbException(
        'add your TMDB API key in lib/config.dart (kTmdbApiKeyFallback)',
      );
    }
  }
}
