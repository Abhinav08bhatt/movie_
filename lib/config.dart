/// TMDB v3 API key.
///
/// Paste it in [kTmdbApiKeyFallback], or run with:
/// `flutter run --dart-define=TMDB_API_KEY=your_key`
const String kTmdbApiKey = String.fromEnvironment(
  'TMDB_API_KEY',
  defaultValue: kTmdbApiKeyFallback,
);

const String kTmdbApiKeyFallback = 'ba66b721706ca1ce246e29f35eb265f2';
