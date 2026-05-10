// lib/data/remote/api_exception.dart
class ApiException implements Exception {
  ApiException(this.status, this.message, {this.detail});

  final int status;
  final String message;
  final Object? detail;

  bool get isUnauthorized => status == 401;
  bool get isForbidden => status == 403;
  bool get isNotFound => status == 404;
  bool get isServerError => status >= 500;

  @override
  String toString() => 'ApiException($status): $message';
}
