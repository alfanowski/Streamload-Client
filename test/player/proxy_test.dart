// test/player/proxy_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:streamload_client/player/proxy.dart';
import 'package:streamload_client/player/session.dart';

void main() {
  late LocalProxyServer proxy;
  late PlaybackSessionRegistry registry;

  setUp(() async {
    registry = PlaybackSessionRegistry(ttl: const Duration(hours: 1));
    proxy = await LocalProxyServer.start(registry: registry);
  });

  tearDown(() async {
    await proxy.stop();
  });

  test('binds on 127.0.0.1 with system-assigned port', () {
    expect(proxy.port, greaterThan(0));
    expect(proxy.baseUrl, startsWith('http://127.0.0.1:'));
  });

  test('GET /health returns 200 ok', () async {
    final resp = await http.get(Uri.parse('${proxy.baseUrl}/health'));
    expect(resp.statusCode, 200);
    expect(resp.body, 'ok');
  });

  test('unknown route returns 404', () async {
    final resp = await http.get(Uri.parse('${proxy.baseUrl}/nope'));
    expect(resp.statusCode, 404);
  });
}
