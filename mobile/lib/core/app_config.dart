class AppConfig {
  static const bool isProduction = bool.fromEnvironment('IS_PROD');
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://upgraded-sniffle-xq5p6qgw4vv3pg7p-3001.app.github.dev/',
  );
}
