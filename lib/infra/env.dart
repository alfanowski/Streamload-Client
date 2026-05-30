// lib/infra/env.dart
//
// Backend base URL, resolved per build mode:
//   - debug   (`flutter run`)            → local dev server  http://127.0.0.1:8000
//   - release (`flutter build …`)        → production        https://api.streamload.capytal.tech
//
// So you don't pass any flag day-to-day: running the app in dev hits your local
// backend (local Postgres), and a release build hits the real VPS. An explicit
// `--dart-define=STREAMLOAD_API_BASE_URL=…` still overrides both — handy for
// pointing a debug build at prod, or a release build at a staging box.
import 'package:flutter/foundation.dart' show kReleaseMode;

class Env {
  Env._();

  /// Production backend (the DigitalOcean VPS, HTTPS via Caddy).
  static const String _prodUrl = 'https://api.streamload.capytal.tech';

  /// Local dev backend (granian on the host). macOS desktop reaches the host
  /// loopback directly; this is the local Postgres-backed stack.
  static const String _devUrl = 'http://127.0.0.1:8000';

  /// Set only when explicitly injected at build time. Empty otherwise.
  static const String _override = String.fromEnvironment(
    'STREAMLOAD_API_BASE_URL',
  );

  /// The base URL the app talks to. Explicit override wins; otherwise the
  /// build mode decides (release → prod, debug → local).
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    return kReleaseMode ? _prodUrl : _devUrl;
  }
}
