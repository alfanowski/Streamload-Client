// test/plugins/host/url_host_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/host/url_host.dart';

void main() {
  test('absolute resolves a relative path against a base', () {
    expect(
      UrlHost.absolute('/storage/key', 'https://upstream.example/it/master.m3u8'),
      'https://upstream.example/storage/key',
    );
  });

  test('absolute is a no-op on already-absolute URLs', () {
    expect(
      UrlHost.absolute('https://other.example/x', 'https://upstream.example/'),
      'https://other.example/x',
    );
  });

  test('absolute resolves protocol-relative URLs', () {
    expect(
      UrlHost.absolute('//cdn.example/x.ts', 'https://upstream.example/'),
      'https://cdn.example/x.ts',
    );
  });
}
