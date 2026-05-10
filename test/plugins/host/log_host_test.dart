// test/plugins/host/log_host_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/host/log_host.dart';

void main() {
  test('dispatch routes by level + tags with plugin name', () {
    final captured = <String>[];
    final host = LogHost(
      sink: (level, tag, msg) =>
          captured.add('${level.name}|$tag|$msg'),
    );

    host.handle('echo', 'debug', 'hello');
    host.handle('echo', 'info', 'started');
    host.handle('sc', 'warn', 'rate limit');
    host.handle('sc', 'error', 'boom');

    expect(captured, [
      'debug|plugin:echo|hello',
      'info|plugin:echo|started',
      'warn|plugin:sc|rate limit',
      'error|plugin:sc|boom',
    ]);
  });

  test('unknown level falls back to info', () {
    final captured = <String>[];
    final host = LogHost(
      sink: (level, tag, msg) => captured.add('${level.name}|$msg'),
    );
    host.handle('echo', 'made_up_level', 'hi');
    expect(captured.single, 'info|hi');
  });
}
