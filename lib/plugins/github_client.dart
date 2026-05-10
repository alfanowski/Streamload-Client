// lib/plugins/github_client.dart
import 'dart:convert';

import 'package:dio/dio.dart';

class GithubClient {
  GithubClient({
    required this.owner,
    required this.repo,
    required this.token,
    Dio? dio,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://api.github.com',
              headers: {
                'Accept': 'application/vnd.github.v3+json',
                'Authorization': 'Bearer $token',
                'X-GitHub-Api-Version': '2022-11-28',
              },
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
              validateStatus: (_) => true,
            ));

  final String owner;
  final String repo;
  final String token;
  final Dio _dio;

  /// GET /repos/{owner}/{repo}/contents/{path} — returns the parsed JSON body
  /// (which has `{ name, sha, content (base64), encoding, ... }` for files).
  Future<Map<String, dynamic>> getContents(String path) async {
    final resp = await _dio.get<dynamic>('/repos/$owner/$repo/contents/$path');
    if (resp.statusCode != 200) {
      throw StateError(
        'github: GET contents/$path → ${resp.statusCode} ${resp.data}',
      );
    }
    return resp.data as Map<String, dynamic>;
  }

  /// Fetch `registry.json` decoded from base64.
  Future<Map<String, dynamic>> getRegistry() async {
    final raw = await getContents('registry.json');
    final encoded = (raw['content'] as String).replaceAll('\n', '');
    final decoded = utf8.decode(base64.decode(encoded));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }

  /// Fetch a plugin .js file as raw text (uses `Accept: application/vnd.github.v3.raw`).
  Future<String> getPluginSource(String filePath) async {
    final resp = await _dio.get<dynamic>(
      '/repos/$owner/$repo/contents/$filePath',
      options: Options(
        headers: {'Accept': 'application/vnd.github.v3.raw'},
        responseType: ResponseType.plain,
      ),
    );
    if (resp.statusCode != 200) {
      throw StateError(
        'github: GET raw $filePath → ${resp.statusCode} ${resp.data}',
      );
    }
    return resp.data as String;
  }

  /// Sanity check the PAT can read the registry. Used by the onboarding wizard.
  /// Returns true on 200, false on 401/403/404, throws on anything else.
  Future<bool> verifyAccess() async {
    final resp =
        await _dio.get<dynamic>('/repos/$owner/$repo/contents/registry.json');
    if (resp.statusCode == 200) return true;
    if (resp.statusCode == 401 ||
        resp.statusCode == 403 ||
        resp.statusCode == 404) {
      return false;
    }
    throw StateError('github: verify failed → ${resp.statusCode}');
  }
}
