abstract final class ApiConfig {
  /// Passed at build/run time via `--dart-define=API_BASE_URL=https://...`.
  /// Defaults to the Android emulator loopback address for local development.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5067',
  );

  static const String apiPrefix = '/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
