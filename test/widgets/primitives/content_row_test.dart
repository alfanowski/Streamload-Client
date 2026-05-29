import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';
import 'package:streamload_client/presentation/widgets/primitives/content_row.dart';

MediaCardVm _vm(int id) => MediaCardVm(
      tmdbId: id,
      mediaType: 'movie',
      title: 'Title $id',
      posterUrl: null,
      metaLine: '2024',
    );

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: SizedBox(height: 320, child: child)));

void main() {
  testWidgets('renders header and items when non-empty', (tester) async {
    await tester.pumpWidget(_host(
      ContentRow(title: 'Tendenze oggi', items: [_vm(1), _vm(2), _vm(3)]),
    ));
    await tester.pump();
    expect(find.text('Tendenze oggi'), findsOneWidget);
    expect(find.text('Title 1'), findsOneWidget);
  });

  testWidgets('renders NOTHING when items is empty (no empty hole)',
      (tester) async {
    // Host in a min-size Column so the row's own intrinsic height shows
    // through (a fixed-height SizedBox would mask a zero-height child).
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [ContentRow(title: 'Vuota', items: [])],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Vuota'), findsNothing);
    expect(find.byType(ContentRow), findsOneWidget); // present...
    final size = tester.getSize(find.byType(ContentRow));
    expect(size.height, 0); // ...but takes zero space
  });

  testWidgets('skeleton variant shows placeholder tiles', (tester) async {
    await tester.pumpWidget(_host(
      const ContentRow.skeleton(title: 'Caricamento', placeholderCount: 4),
    ));
    await tester.pump();
    expect(find.text('Caricamento'), findsOneWidget);
    expect(find.byKey(const Key('row-skeleton-tile')), findsNWidgets(4));
  });

  testWidgets('tapping an item reports the right vm', (tester) async {
    MediaCardVm? tapped;
    await tester.pumpWidget(_host(
      ContentRow(
        title: 'Row',
        items: [_vm(7), _vm(8)],
        onItemTap: (vm) => tapped = vm,
      ),
    ));
    await tester.pump();
    await tester.tap(find.text('Title 7'));
    expect(tapped?.tmdbId, 7);
  });
}
