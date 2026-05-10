import 'dart:async';

import 'package:dio/dio.dart';

class DeviceCodeRequest {
  const DeviceCodeRequest({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.pollInterval,
  });

  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final Duration expiresIn;
  final Duration pollInterval;
}

class DeviceFlowDenied implements Exception {
  const DeviceFlowDenied();
  @override
  String toString() => 'GitHub device flow: user denied authorization';
}

class DeviceFlowExpired implements Exception {
  const DeviceFlowExpired();
  @override
  String toString() => 'GitHub device flow: code expired before authorization';
}

/// GitHub OAuth Device Flow client. The Client ID is public by design; the
/// app embeds it as a const. No client_secret is needed for device flow.
///
/// Flow:
///   1. POST /login/device/code → get { device_code, user_code, verification_uri, ... }
///   2. Show user_code + open verification_uri in the browser
///   3. Poll POST /login/oauth/access_token until 200 (token), access_denied,
///      or our timeout
class GithubOAuth {
  GithubOAuth({required this.clientId, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Accept': 'application/json'},
              validateStatus: (_) => true,
            ));

  final String clientId;
  final Dio _dio;

  /// Step 1: ask GitHub for a device code.
  Future<DeviceCodeRequest> requestDeviceCode({String scope = 'repo user:email'}) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      'https://github.com/login/device/code',
      data: {'client_id': clientId, 'scope': scope},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    if (resp.statusCode != 200 || resp.data == null) {
      throw StateError('github device/code → ${resp.statusCode}: ${resp.data}');
    }
    final body = resp.data!;
    return DeviceCodeRequest(
      deviceCode: body['device_code'] as String,
      userCode: body['user_code'] as String,
      verificationUri: body['verification_uri'] as String,
      expiresIn: Duration(seconds: (body['expires_in'] as num).toInt()),
      pollInterval: Duration(seconds: (body['interval'] as num).toInt()),
    );
  }

  /// Step 2: poll until the user authorizes (or denies / times out).
  ///
  /// Errors raised:
  /// - [DeviceFlowDenied] on `access_denied`
  /// - [DeviceFlowExpired] on `expired_token` OR when `timeout` elapses
  /// - [StateError] on any other unexpected response
  Future<String> pollForToken({
    required String deviceCode,
    required Duration interval,
    required Duration timeout,
  }) async {
    final deadline = DateTime.now().add(timeout);
    var currentInterval = interval;
    while (true) {
      final resp = await _dio.post<Map<String, dynamic>>(
        'https://github.com/login/oauth/access_token',
        data: {
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final body = resp.data ?? const <String, dynamic>{};
      if (body['access_token'] is String) {
        return body['access_token'] as String;
      }
      final err = body['error'] as String?;
      bool isSlowDown = false;
      switch (err) {
        case 'authorization_pending':
          break; // keep polling at currentInterval
        case 'slow_down':
          isSlowDown = true;
          currentInterval = currentInterval + const Duration(seconds: 5);
          break;
        case 'access_denied':
          throw const DeviceFlowDenied();
        case 'expired_token':
          throw const DeviceFlowExpired();
        default:
          throw StateError('github access_token → $err / $body');
      }
      // After authorization_pending: if deadline already passed, give up.
      // After slow_down: wait up to the remaining budget so the *next* poll
      // can still run (the server asked us to back off, not to give up).
      final remaining = deadline.difference(DateTime.now());
      if (!isSlowDown && remaining <= Duration.zero) {
        throw const DeviceFlowExpired();
      }
      if (remaining > Duration.zero) {
        final delay =
            currentInterval < remaining ? currentInterval : remaining;
        await Future<void>.delayed(delay);
      }
    }
  }
}
