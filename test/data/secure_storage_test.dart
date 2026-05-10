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

  test('github PAT round-trips', () async {
    await s.setGithubPat('github_pat_xyz');
    expect(await s.githubPat(), 'github_pat_xyz');
    await s.clearGithubPat();
    expect(await s.githubPat(), isNull);
  });
}
