// test/data/secure_storage_test.dart
//
// We don't unit-test the actual Keychain backend (requires platform); we
// confirm the wrapper exposes the right named accessors and round-trips
// through an injected map-backed implementation.
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/secure/secure_storage.dart';

class _MemoryBackend implements SecureKvBackend {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;

  @override
  Future<void> delete(String key) async => _data.remove(key);
}

void main() {
  late SecureStorage s;

  setUp(() {
    s = SecureStorage(backend: _MemoryBackend());
  });

  test('session cookie round-trips', () async {
    await s.setSessionCookie('abc=123');
    expect(await s.sessionCookie(), 'abc=123');
    await s.clearSessionCookie();
    expect(await s.sessionCookie(), isNull);
  });

  test('github token round-trips', () async {
    await s.setGithubToken('ghu_xyz');
    expect(await s.githubToken(), 'ghu_xyz');
    await s.clearGithubToken();
    expect(await s.githubToken(), isNull);
  });

  test('github token falls back to legacy PAT key', () async {
    // Write directly to the legacy key to simulate a pre-OAuth user.
    final backend = _MemoryBackend();
    await backend.write('streamload.github_pat', 'ghp_legacy');
    final storage = SecureStorage(backend: backend);
    expect(await storage.githubToken(), 'ghp_legacy');
  });
}
