// lib/config/env.dart
class Env {
  // defaultValue boleh lo ganti ke IP/Wi-Fi kalau gak pakai ADB reverse
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static final Uri _apiBaseUri = Uri.parse(apiBaseUrl);

  static String get apiOrigin {
    final origin = Uri(
      scheme: _apiBaseUri.scheme,
      host: _apiBaseUri.host,
      port: _apiBaseUri.hasPort ? _apiBaseUri.port : null,
    );
    return origin.toString();
  }
}
