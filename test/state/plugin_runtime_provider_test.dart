// test/state/plugin_runtime_provider_test.dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/data/local/database.dart';
import 'package:streamload_client/plugins/runtime.dart';
import 'package:streamload_client/state/database_provider.dart';
import 'package:streamload_client/state/plugin_runtime_provider.dart';

void main() {
  test('pluginRuntimeProvider returns a PluginRuntime singleton', () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final runtime = await container.read(pluginRuntimeProvider.future);
    expect(runtime, isA<PluginRuntime>());
  });

  test('pluginRuntimeProvider returns the same instance on repeated reads',
      () async {
    final db = StreamloadDatabase.test(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
    ]);
    addTearDown(() async {
      container.dispose();
      await db.close();
    });

    final a = await container.read(pluginRuntimeProvider.future);
    final b = await container.read(pluginRuntimeProvider.future);
    expect(identical(a, b), isTrue);
  });
}
