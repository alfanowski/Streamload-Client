// lib/plugins/host/http_host.dart
import 'package:dio/dio.dart';

class HttpHost {
  HttpHost._(this._dio);

  /// Production constructor — owns its own dio with the strict defaults.
  factory HttpHost() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (_) => true,
      responseType: ResponseType.plain,
    ));
    return HttpHost._(dio);
  }

  /// Test constructor — injectable dio.
  HttpHost.test(Dio dio) : _dio = dio;

  final Dio _dio;
  static const int _maxBodyBytes = 10 * 1024 * 1024; // 10MB cap

  /// `init` shape: `{ method?, headers?, body?, cookies? }` — all optional.
  Future<Map<String, dynamic>> fetch(String url, Map<String, dynamic> init) async {
    final method = (init['method'] as String?)?.toUpperCase() ?? 'GET';
    final headers = Map<String, dynamic>.from(
      (init['headers'] as Map?) ?? <String, dynamic>{},
    );

    // Merge cookies (if any) into a Cookie header, joined with ; .
    final cookieIn = init['cookies'];
    if (cookieIn is Map && cookieIn.isNotEmpty) {
      headers['Cookie'] = cookieIn.entries
          .map((e) => '${e.key}=${e.value}')
          .join('; ');
    }

    final options = RequestOptions(
      path: url,
      method: method,
      headers: headers,
      data: init['body'],
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (_) => true,
      responseType: ResponseType.plain,
    );

    final resp = await _dio.fetch<dynamic>(options);

    final body = resp.data?.toString() ?? '';
    if (body.length > _maxBodyBytes) {
      throw StateError(
        'http_host: response body exceeds 10MB cap (${body.length} bytes)',
      );
    }

    return {
      'status': resp.statusCode ?? 0,
      'headers': _flattenHeaders(resp.headers),
      'body': body,
      'cookies': _parseSetCookie(resp.headers),
      'finalUrl': resp.realUri.toString(),
    };
  }

  Map<String, String> _flattenHeaders(Headers h) {
    final out = <String, String>{};
    h.forEach((name, values) => out[name.toLowerCase()] = values.join(', '));
    return out;
  }

  Map<String, String> _parseSetCookie(Headers h) {
    final out = <String, String>{};
    final raw = h['set-cookie'];
    if (raw == null) return out;
    for (final line in raw) {
      // First name=value pair before any "; " attribute.
      final firstSemi = line.indexOf(';');
      final pair = firstSemi >= 0 ? line.substring(0, firstSemi) : line;
      final eq = pair.indexOf('=');
      if (eq <= 0) continue;
      out[pair.substring(0, eq).trim()] = pair.substring(eq + 1).trim();
    }
    return out;
  }
}
