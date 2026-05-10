// lib/data/secure/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pluggable backend so tests can use an in-memory map.
abstract class SecureKvBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class _FlutterSecureStorageBackend implements SecureKvBackend {
  static const _opts = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  static const _macOpts = MacOsOptions(accessibility: KeychainAccessibility.first_unlock);
  final _storage = const FlutterSecureStorage(iOptions: _opts, mOptions: _macOpts);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Typed Keychain accessors.
class SecureStorage {
  SecureStorage({SecureKvBackend? backend})
      : _backend = backend ?? _FlutterSecureStorageBackend();

  final SecureKvBackend _backend;

  static const _kSessionCookie = 'streamload.session_cookie';
  static const _kGithubPat = 'streamload.github_pat';

  Future<String?> sessionCookie() => _backend.read(_kSessionCookie);
  Future<void> setSessionCookie(String value) =>
      _backend.write(_kSessionCookie, value);
  Future<void> clearSessionCookie() => _backend.delete(_kSessionCookie);

  Future<String?> githubPat() => _backend.read(_kGithubPat);
  Future<void> setGithubPat(String value) => _backend.write(_kGithubPat, value);
  Future<void> clearGithubPat() => _backend.delete(_kGithubPat);
}
