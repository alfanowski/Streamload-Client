// test/plugins/meta_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/meta.dart';

void main() {
  test('accepts a valid meta payload', () {
    final m = PluginMeta.fromJson({
      'short_name': 'echo',
      'display_name': 'Echo',
      'version': '1.0.0',
      'api_version': 1,
      'capabilities': ['movie'],
    });
    expect(m.shortName, 'echo');
    expect(m.capabilities, ['movie']);
  });

  test('validate rejects bad short_name', () {
    final result = PluginMeta.validate({
      'short_name': 'BAD-NAME',
      'display_name': 'X',
      'version': '1.0.0',
      'api_version': 1,
      'capabilities': ['movie'],
    });
    expect(result, contains('short_name'));
  });

  test('validate rejects api_version other than 1', () {
    final result = PluginMeta.validate({
      'short_name': 'echo',
      'display_name': 'Echo',
      'version': '1.0.0',
      'api_version': 2,
      'capabilities': ['movie'],
    });
    expect(result, contains('api_version'));
  });

  test('validate rejects unknown capability', () {
    final result = PluginMeta.validate({
      'short_name': 'echo',
      'display_name': 'Echo',
      'version': '1.0.0',
      'api_version': 1,
      'capabilities': ['movie:made_up'],
    });
    expect(result, contains('capabilities'));
  });

  test('validate rejects bad semver', () {
    final result = PluginMeta.validate({
      'short_name': 'echo',
      'display_name': 'Echo',
      'version': 'not-semver',
      'api_version': 1,
      'capabilities': ['movie'],
    });
    expect(result, contains('version'));
  });

  test('validate returns null for all-good payload', () {
    expect(PluginMeta.validate({
      'short_name': 'echo',
      'display_name': 'Echo',
      'version': '1.0.0',
      'api_version': 1,
      'capabilities': ['movie', 'tv:anime'],
    }), isNull);
  });
}
