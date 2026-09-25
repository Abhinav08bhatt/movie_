import 'package:flutter/material.dart';

import '../screens/details_screen.dart';
import '../screens/library_screen.dart';
import '../screens/search_screen.dart';
import '../session/movie_session.dart';
import '../ui/status_bar.dart';
import '../ui/swipe_poster.dart';
import '../ui/vibe_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = MovieSessionScope.of(context);
    final movie = session.current;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: Stack(
        fit: StackFit.expand,
        children: [
          VibeBackground(posterUrl: movie?.posterUrl),
          Column(
            children: [
              const AppStatusBar(),
              _Header(
                onLibrary: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LibraryScreen()),
                  );
                },
              ),
              if (session.genre != null && movie != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${session.genre!.name}  ·  ${session.remaining} left',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Center(
                    child: session.exploring
                        ? const _LoadingCard()
                        : movie == null
                            ? const _EmptyReel()
                            : SwipePoster(
                                key: ValueKey(movie.id),
                                movie: movie,
                                onPass: session.pass,
                                onWishlist: session.addCurrentToWishlist,
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DetailsScreen(movie: movie),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ),
              _BottomBar(
                exploring: session.exploring,
                onSearch: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                onExplore: () async {
                  await session.explore(context);
                  if (!context.mounted) return;
                  if (session.error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(session.error!)),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLibrary});

  final VoidCallback onLibrary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(text: "i'm "),
                              TextSpan(
                                text: 'AVI',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: ' and i watch'),
                            ],
                          ),
                        ),
                      ),
                      _CountChip(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5EC8F0),
                          Color(0xFF7D5FFF),
                          Color(0xFFE85D8C),
                          Color(0xFFFF8A3D),
                          Color(0xFFE2F163),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: const Color(0xFF1E1E22),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onLibrary,
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(Icons.video_library_outlined, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A30),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Text(
        '342 movies',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
    );
  }
}

class _EmptyReel extends StatelessWidget {
  const _EmptyReel();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C30),
          borderRadius: BorderRadius.circular(36),
        ),
        padding: const EdgeInsets.all(32),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 46, color: Colors.white38),
            SizedBox(height: 18),
            Text(
              'no reel yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'press explore. we’ll pull a random genre and load the whole stack before you swipe.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C30),
          borderRadius: BorderRadius.circular(36),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE2F163)),
            SizedBox(height: 16),
            Text(
              'loading a genre stack…',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.exploring,
    required this.onSearch,
    required this.onExplore,
  });

  final bool exploring;
  final VoidCallback onSearch;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: const Color(0xFF1E1E22),
              borderRadius: BorderRadius.circular(26),
              child: InkWell(
                borderRadius: BorderRadius.circular(26),
                onTap: onSearch,
                child: const SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Icon(Icons.search, color: Colors.white54, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'what would u like...',
                        style: TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: const Color(0xFF1E1E22),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: exploring ? null : onExplore,
              child: SizedBox(
                width: 52,
                height: 52,
                child: exploring
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFE2F163),
                        ),
                      )
                    : const Icon(Icons.explore_outlined, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
