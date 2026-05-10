// test/plugins/updater_test.dart
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/plugins/loader.dart';
import 'package:streamload_client/plugins/updater.dart';
import 'package:streamload_client/state/plugins_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _FakeRef extends Fake implements Ref {}

/// A [PluginRefreshController] whose [refresh] is synchronous so fake_async
/// can drive time without needing to pump a real event loop.
class _SyncRefreshController extends PluginRefreshController {
  _SyncRefreshController() : super(_FakeRef());

  int callCount = 0;
  bool shouldThrow = false;

  @override
  Future<void> refresh() {
    callCount++;
    if (shouldThrow) {
      return Future<void>.error(StateError('no PAT'));
    }
    state = AsyncData(RefreshResult(mounted: [], failed: [], removed: []));
    return Future<void>.value();
  }
}

/// Builds a [ProviderContainer] where [pluginRefreshControllerProvider] is
/// replaced with the given [controller], and returns both the container and
/// a [PluginUpdater] backed by that container's [Ref].
({ProviderContainer container, PluginUpdater updater, _SyncRefreshController ctrl})
    _build({bool shouldThrow = false}) {
  final ctrl = _SyncRefreshController()..shouldThrow = shouldThrow;

  // We need to supply a Ref that routes reads to our overridden container.
  // The simplest approach: create the container, then create PluginUpdater
  // with the container's ref obtained from a one-shot provider.
  late Ref capturedRef;

  final container = ProviderContainer(
    overrides: [
      pluginRefreshControllerProvider
          .overrideWith((_) => ctrl),
    ],
  );

  // Use a helper provider to capture a live Ref from within the container.
  final refCapture = Provider<void>((ref) {
    capturedRef = ref;
  });
  container.read(refCapture); // forces the provider to build and captures ref

  final updater = PluginUpdater(capturedRef);
  return (container: container, updater: updater, ctrl: ctrl);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    registerFallbackValue(
      RefreshResult(mounted: [], failed: [], removed: []),
    );
  });

  group('PluginUpdater', () {
    test('calls refresh once immediately on start()', () {
      fakeAsync((async) {
        final (:container, :updater, :ctrl) = _build();
        addTearDown(container.dispose);

        updater.start();
        async.flushMicrotasks();

        expect(ctrl.callCount, 1);

        updater.stop();
      });
    });

    test('calls refresh again after 30 minutes', () {
      fakeAsync((async) {
        final (:container, :updater, :ctrl) = _build();
        addTearDown(container.dispose);

        updater.start();
        async.flushMicrotasks(); // immediate tick → count == 1

        // Almost 30 min — no periodic tick yet.
        async.elapse(const Duration(minutes: 29));
        expect(ctrl.callCount, 1);

        // Cross the 30-min boundary → second tick.
        async.elapse(const Duration(minutes: 1));
        async.flushMicrotasks();
        expect(ctrl.callCount, 2);

        // Another full 30 min → third tick.
        async.elapse(const Duration(minutes: 30));
        async.flushMicrotasks();
        expect(ctrl.callCount, 3);

        updater.stop();
      });
    });

    test('stop() cancels the timer — no more ticks after stop', () {
      fakeAsync((async) {
        final (:container, :updater, :ctrl) = _build();
        addTearDown(container.dispose);

        updater.start();
        async.flushMicrotasks();
        updater.stop();

        // Advance well past the 30-min mark.
        async.elapse(const Duration(hours: 2));
        async.flushMicrotasks();

        // Still just the one immediate tick from start().
        expect(ctrl.callCount, 1);
      });
    });

    test('start() is idempotent — second start does not add a second timer',
        () {
      fakeAsync((async) {
        final (:container, :updater, :ctrl) = _build();
        addTearDown(container.dispose);

        updater.start();
        updater.start(); // second call: fires another immediate refresh but
        //                  must NOT create a second periodic timer.
        async.flushMicrotasks();

        final countAfterStart = ctrl.callCount; // 2 immediate refreshes

        async.elapse(const Duration(minutes: 30));
        async.flushMicrotasks();
        // Exactly ONE periodic timer → exactly one more tick.
        expect(ctrl.callCount, countAfterStart + 1);

        updater.stop();
      });
    });

    test('tolerates refresh() throwing — does not propagate the error', () {
      fakeAsync((async) {
        final (:container, :updater, :ctrl) =
            _build(shouldThrow: true);
        addTearDown(container.dispose);

        // start() must not throw even though refresh() throws internally.
        expect(() {
          updater.start();
          async.flushMicrotasks();
        }, returnsNormally);

        expect(ctrl.callCount, 1);

        // Periodic tick also swallows the error.
        async.elapse(const Duration(minutes: 30));
        async.flushMicrotasks();
        expect(ctrl.callCount, 2);

        updater.stop();
      });
    });
  });
}
