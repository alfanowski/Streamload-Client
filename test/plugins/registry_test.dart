// test/plugins/registry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/plugins/registry.dart';

void main() {
  test('detects new plugins (in remote, not local)', () {
    final diff = RegistryDiff.compute(
      remote: const [
        RegistryEntry(shortName: 'echo', file: 'plugins/echo.js', version: '1.0.0', sha256: 'aa'),
        RegistryEntry(shortName: 'sc', file: 'plugins/sc.js', version: '1.0.0', sha256: 'bb'),
      ],
      installed: const [
        InstalledRecord(shortName: 'echo', version: '1.0.0', sha256: 'aa'),
      ],
    );
    expect(diff.added.map((e) => e.shortName), ['sc']);
    expect(diff.changed, isEmpty);
    expect(diff.removed, isEmpty);
    expect(diff.unchanged.map((e) => e.shortName), ['echo']);
  });

  test('detects sha256 changes (same short_name, different sha)', () {
    final diff = RegistryDiff.compute(
      remote: const [
        RegistryEntry(shortName: 'echo', file: 'plugins/echo.js', version: '1.0.1', sha256: 'cc'),
      ],
      installed: const [
        InstalledRecord(shortName: 'echo', version: '1.0.0', sha256: 'aa'),
      ],
    );
    expect(diff.changed.map((e) => e.shortName), ['echo']);
    expect(diff.added, isEmpty);
    expect(diff.removed, isEmpty);
  });

  test('detects removed plugins (in local, not in remote)', () {
    final diff = RegistryDiff.compute(
      remote: const [],
      installed: const [
        InstalledRecord(shortName: 'echo', version: '1.0.0', sha256: 'aa'),
      ],
    );
    expect(diff.removed, ['echo']);
    expect(diff.added, isEmpty);
    expect(diff.changed, isEmpty);
  });
}
