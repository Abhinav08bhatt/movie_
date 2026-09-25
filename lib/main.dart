import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'session/movie_session.dart';
import 'tmdb/tmdb_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
  );
  runApp(MovieApp(session: MovieSession(tmdb: TmdbService())));
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key, required this.session});

  final MovieSession session;

  @override
  Widget build(BuildContext context) {
    return MovieSessionScope(
      session: session,
      child: MaterialApp(
        title: 'movie_',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F12),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE2F163),
            surface: Color(0xFF1B1B1F),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
