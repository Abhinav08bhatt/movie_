import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../screens/details_screen.dart';
import '../session/movie_session.dart';
import '../ui/status_bar.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = MovieSessionScope.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        body: Column(
          children: [
            const AppStatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  const Text(
                    'library',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const TabBar(
              indicatorColor: Color(0xFFE2F163),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: [
                Tab(text: 'wishlist'),
                Tab(text: 'downloaded'),
                Tab(text: 'watched'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _PosterGrid(movies: session.wishlist),
                  _PosterGrid(movies: session.downloaded),
                  _PosterGrid(movies: session.watched),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterGrid extends StatelessWidget {
  const _PosterGrid({required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: Text(
          'nothing here yet',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2 / 3,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DetailsScreen(movie: movie)),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: movie.thumbUrl == null
                ? const ColoredBox(color: Color(0xFF2C2C30))
                : CachedNetworkImage(
                    imageUrl: movie.thumbUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}
