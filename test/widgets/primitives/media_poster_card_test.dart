import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/presentation/view_models/media_card_vm.dart';
import 'package:streamload_client/presentation/widgets/primitives/media_poster_card.dart';

const _vm = MediaCardVm(
  tmdbId: 1,
  mediaType: 'movie',
  title: 'Dune',
  posterUrl: null,
  metaLine: '2024 · Film',
);

Widget _host(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders title and meta line', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140),
    ));
    await tester.pump();
    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('2024 · Film'), findsOneWidget);
  });

  testWidgets('omits meta line when empty', (tester) async {
    // posterUrl set → AspectRatioMedia shows the image placeholder (no
    // initials Text), so the only Text descendant should be the title.
    const vm = MediaCardVm(
      tmdbId: 2,
      mediaType: 'movie',
      title: 'X',
      posterUrl: 'https://example.test/p.jpg',
      metaLine: '',
    );
    await tester.pumpWidget(_host(const MediaPosterCard(item: vm, width: 140)));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    // Only the title Text under the card — no empty meta Text node.
    expect(
      find.descendant(
        of: find.byType(MediaPosterCard),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows a progress bar when progress > 0', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140, progress: 0.5),
    ));
    await tester.pump();
    expect(find.byKey(const Key('poster-progress')), findsOneWidget);
  });

  testWidgets('hides the progress bar when progress is null', (tester) async {
    await tester.pumpWidget(_host(
      const MediaPosterCard(item: _vm, width: 140),
    ));
    await tester.pump();
    expect(find.byKey(const Key('poster-progress')), findsNothing);
  });

  testWidgets('invokes onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(
      MediaPosterCard(item: _vm, width: 140, onTap: () => taps++),
    ));
    await tester.pump();
    await tester.tap(find.byType(MediaPosterCard));
    expect(taps, 1);
  });
}
