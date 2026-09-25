import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../screens/details_screen.dart';
import '../session/movie_session.dart';
import '../ui/status_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Movie> _results = [];
  bool _loading = false;
  String? _error;
  int? _openingId;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _search(value);
    });
  }

  Future<void> _search(String value) async {
    final session = MovieSessionScope.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await session.tmdb.search(value);
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _open(Movie preview) async {
    final session = MovieSessionScope.of(context);
    setState(() => _openingId = preview.id);
    try {
      final movie = await session.openFromSearch(context, preview);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetailsScreen(movie: movie)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Column(
        children: [
          const AppStatusBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onChanged,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: const Color(0xFFE2F163),
                    decoration: InputDecoration(
                      hintText: 'what would u like...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E1E22),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(26),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              color: Color(0xFFE2F163),
              backgroundColor: Colors.transparent,
              minHeight: 2,
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!, style: const TextStyle(color: Colors.white54)),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final movie = _results[index];
                final opening = _openingId == movie.id;
                return ListTile(
                  onTap: opening ? null : () => _open(movie),
                  contentPadding: const EdgeInsets.all(8),
                  tileColor: const Color(0xFF1E1E22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: movie.thumbUrl == null
                        ? const SizedBox(width: 46, height: 68)
                        : CachedNetworkImage(
                            imageUrl: movie.thumbUrl!,
                            width: 46,
                            height: 68,
                            fit: BoxFit.cover,
                          ),
                  ),
                  title: Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    movie.year,
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: opening
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
