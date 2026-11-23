/// API origin supplied at build time for deployed builds.
///
/// Local development defaults to Flask on port 5000. For deployment, build
/// with `--dart-define=API_BASE_URL=https://your-api.example.com`.
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );

  static Uri endpoint(String path) => Uri.parse('$baseUrl/$path');
}
