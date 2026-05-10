// lib/plugins/host/url_host.dart
class UrlHost {
  UrlHost._();

  /// Resolve a possibly-relative URL against a base, mirroring whatwg URL
  /// semantics. Uses the standard `Uri.resolve`.
  static String absolute(String maybeRelative, String base) {
    final baseUri = Uri.parse(base);
    return baseUri.resolve(maybeRelative).toString();
  }
}
