import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/widgets/primitives/async_state_view.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('loading state shows the provided loading widget',
      (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.loading(),
        loading: const Text('LOADING'),
        onRetry: () {},
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('LOADING'), findsOneWidget);
  });

  testWidgets('data state shows the data builder', (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.data([1, 2, 3]),
        loading: const Text('LOADING'),
        onRetry: () {},
        data: (d) => Text('DATA ${d.length}'),
      ),
    ));
    expect(find.text('DATA 3'), findsOneWidget);
  });

  testWidgets('empty predicate routes to the empty state', (tester) async {
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: const AsyncValue.data(<int>[]),
        loading: const Text('LOADING'),
        onRetry: () {},
        isEmpty: (d) => d.isEmpty,
        empty: const Text('EMPTY'),
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('EMPTY'), findsOneWidget);
    expect(find.text('DATA'), findsNothing);
  });

  testWidgets('error state shows retry and invokes onRetry', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_host(
      AsyncStateView<List<int>>(
        value: AsyncValue.error('boom', StackTrace.empty),
        loading: const Text('LOADING'),
        onRetry: () => retried++,
        data: (d) => const Text('DATA'),
      ),
    ));
    expect(find.text('Riprova'), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    expect(retried, 1);
  });
}
