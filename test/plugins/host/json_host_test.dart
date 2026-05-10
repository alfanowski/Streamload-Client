// test/plugins/host/json_host_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/host/json_host.dart';

void main() {
  test('parse decodes JSON to native Dart', () {
    expect(JsonHost.parse('{"a":1,"b":["x","y"]}'),
        {'a': 1, 'b': ['x', 'y']});
  });

  test('stringify encodes back to JSON', () {
    expect(JsonHost.stringify({'a': 1}), '{"a":1}');
  });

  test('parse rejects malformed JSON with FormatException', () {
    expect(() => JsonHost.parse('not json'), throwsFormatException);
  });
}
