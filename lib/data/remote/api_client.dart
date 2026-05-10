// lib/data/remote/api_client.dart
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import '../../infra/env.dart';
import 'api_exception.dart';

/// Dio wrapper. Owns the cookie jar so the backend session persists across
/// app restarts (jar lives in app support dir).
class ApiClient {
  ApiClient._(this._dio);

  /// Real client — call `await ApiClient.create()`.
  static Future<ApiClient> create() async {
    final supportDir = await getApplicationSupportDirectory();
    final jar = PersistCookieJar(
      ignoreExpires: false,
      storage: FileStorage('${supportDir.path}/cookies/'),
    );
    final dio = Dio(BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      validateStatus: (_) => true, // we map status → ApiException ourselves
    ));
    dio.interceptors.add(CookieManager(jar));
    return ApiClient._(dio);
  }

  /// Test ctor — inject your own Dio (typically a mocktail mock).
  ApiClient.test(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return _unwrap(
      () => _dio.get<dynamic>(path, queryParameters: query),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    return _unwrap(
      () => _dio.post<dynamic>(path, data: body, queryParameters: query),
    );
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
  }) async {
    return _unwrap(
      () => _dio.put<dynamic>(path, data: body, queryParameters: query),
    );
  }

  Future<void> delete(String path, {Map<String, dynamic>? query}) async {
    await _unwrap(
      () => _dio.delete<dynamic>(path, queryParameters: query),
    );
  }

  Future<Map<String, dynamic>> _unwrap(
    Future<Response<dynamic>> Function() call,
  ) async {
    Response<dynamic> resp;
    try {
      resp = await call();
    } on DioException catch (e) {
      // Network error or thrown response.
      final r = e.response;
      if (r != null) {
        throw _toApi(r);
      }
      throw ApiException(0, e.message ?? 'network error');
    }
    if (resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300) {
      final body = resp.data;
      if (body is Map<String, dynamic>) return body;
      // 204 / empty body → return {}
      return <String, dynamic>{};
    }
    throw _toApi(resp);
  }

  ApiException _toApi(Response<dynamic> r) {
    final data = r.data;
    String msg = 'http ${r.statusCode}';
    Object? detail;
    if (data is Map && data['detail'] is String) {
      msg = data['detail'] as String;
    } else if (data is Map) {
      detail = data;
      if (data['message'] is String) msg = data['message'] as String;
    }
    return ApiException(r.statusCode ?? 0, msg, detail: detail);
  }
}
