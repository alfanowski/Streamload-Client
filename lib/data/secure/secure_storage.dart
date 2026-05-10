// lib/data/secure/secure_storage.dart
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../infra/logger.dart';

/// Pluggable backend so tests can use an in-memory map.
abstract class SecureKvBackend {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Default backend: tries Keychain first (for signed builds), falls back to
/// shared_preferences when Keychain is unavailable (typically unsigned dev
/// runs on macOS, where errSecMissingEntitlement -34018 is raised).
///
/// The fallback is sticky per-key: once a key was last written via prefs, we
/// keep using prefs for it to avoid mid-session inconsistency.
class _FallbackSecureBackend implements SecureKvBackend {
  static const _iOpts = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
  static const _macOpts = MacOsOptions(accessibility: KeychainAccessibility.first_unlock);
  final _keychain = const FlutterSecureStorage(iOptions: _iOpts, mOptions: _macOpts);
  final _log = Logger('secure_storage');
  final _prefsFallback = <String>{};
  Future<SharedPreferences>? _prefs;

  Future<SharedPreferences> _getPrefs() {
    return _prefs ??= SharedPreferences.getInstance();
  }

  @override
  Future<String?> read(String key) async {
    if (_prefsFallback.contains(key)) {
      return (await _getPrefs()).getString('secure.$key');
    }
    try {
      return await _keychain.read(key: key);
    } on PlatformException catch (e) {
      _log.warn('keychain read failed for $key (${e.code}); using prefs');
      _prefsFallback.add(key);
      return (await _getPrefs()).getString('secure.$key');
    }
  }

  @override
  Future<void> write(String key, String value) async {
    if (_prefsFallback.contains(key)) {
      await (await _getPrefs()).setString('secure.$key', value);
      return;
    }
    try {
      await _keychain.write(key: key, value: value);
    } on PlatformException catch (e) {
      _log.warn('keychain write failed for $key (${e.code}); using prefs');
      _prefsFallback.add(key);
      await (await _getPrefs()).setString('secure.$key', value);
    }
  }

  @override
  Future<void> delete(String key) async {
    if (_prefsFallback.contains(key)) {
      await (await _getPrefs()).remove('secure.$key');
      return;
    }
    try {
      await _keychain.delete(key: key);
    } on PlatformException catch (e) {
      _log.warn('keychain delete failed for $key (${e.code}); using prefs');
      _prefsFallback.add(key);
      await (await _getPrefs()).remove('secure.$key');
    }
  }
}

/// Typed Keychain accessors.
class SecureStorage {
  SecureStorage({SecureKvBackend? backend})
      : _backend = backend ?? _FallbackSecureBackend();

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
