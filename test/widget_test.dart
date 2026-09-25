import 'package:flutter_test/flutter_test.dart';

import 'package:movie_/main.dart';
import 'package:movie_/session/movie_session.dart';
import 'package:movie_/tmdb/tmdb_service.dart';

void main() {
  testWidgets('home shows explore empty state', (WidgetTester tester) async {
    await tester.pumpWidget(
      MovieApp(session: MovieSession(tmdb: TmdbService())),
    );

    expect(find.text('no reel yet'), findsOneWidget);
    expect(find.textContaining('AVI'), findsOneWidget);
    expect(find.text('movie:time'), findsOneWidget);
  });
}
