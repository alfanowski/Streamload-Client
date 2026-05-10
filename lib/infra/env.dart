// lib/infra/env.dart
//
// Build-time environment. Inject the backend URL with:
//   flutter run --dart-define=STREAMLOAD_API_BASE_URL=https://your-vps.example.com
//
// Defaults to local dev server.

class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'STREAMLOAD_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}
