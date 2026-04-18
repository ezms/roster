class AppConfig {
  static const bool isProduction = bool.fromEnvironment('IS_PROD');
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3001/',
  );
}
