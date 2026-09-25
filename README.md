# movie:time

Flutter app for browsing movies (TMDB). Android + Linux.

## Run

```bash
flutter pub get
flutter run --dart-define=TMDB_API_KEY=your_key
```

You can also paste a key into `kTmdbApiKeyFallback` in `lib/config.dart` for local use. Do not commit a real key.

## Layout

| Path | What |
| --- | --- |
| `lib/` | App code |
| `android/` | Android host |
| `linux/` | Linux host |
| `test/` | Widget tests |
| `mock_ups/` | Design screenshots (not bundled in the app) |

Build a debug APK with `flutter build apk` — do not check APKs into git.
