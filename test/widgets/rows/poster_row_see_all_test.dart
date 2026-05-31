import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streamload_client/domain/models/media_summary.dart';
import 'package:streamload_client/presentation/widgets/rows/poster_row.dart';

void main() {
  testWidgets('tap "Vedi tutti →" chiama onSeeAll', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PosterRow(
          title: 'Film',
          items: const [
            MediaSummary(tmdbId: 1, mediaType: 'movie', title: 'Dune'),
          ],
          onSeeAll: () => tapped = true,
        ),
      ),
    ));
    await tester.pump();

    expect(find.text('Vedi tutti →'), findsOneWidget);
    await tester.tap(find.text('Vedi tutti →'));
    expect(tapped, isTrue);
  });
}
