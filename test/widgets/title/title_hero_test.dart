// test/widgets/title/title_hero_test.dart
//
// Title page hero — Phase E1 of sub-plan 8. Verifies:
//
//   - renders title + meta line + share / list CTAs
//   - movie title primary CTA reads "▶ Guarda"
//   - tv title primary CTA reads "▶ Guarda S1 E1" when no progress yet
//   - tv title primary CTA reads "▶ Riprendi" when continue-watching has
//     a record for this title
//   - tapping the share circle copies the deep link to the clipboard
//
// We override every provider TitleHero reads (favorites, continue
// watching, plugin access, trailer) so the widget renders synchronously
// without hitting the network.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/favorites_api.dart';
import 'package:streamload_client/domain/models/catalog_item.dart';
import 'package:streamload_client/presentation/widgets/title/title_hero.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/continue_watching_provider.dart';
import 'package:streamload_client/state/home_rows_provider.dart';
import 'package:streamload_client/state/plugin_access_provider.dart';
import 'package:streamload_client/domain/models/continue_watching_item.dart';

class _FavApiMock extends Mock implements FavoritesApi {}

void main() {
  Widget host(
    Widget child, {
    List<Override> extra = const [],
    Size size = const Size(1280, 720),
  }) {
    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
    return ProviderScope(
      overrides: [
        favoritesApiProvider.overrideWith((_) async => fav),
        // Default: no progress, no trailer, plugin available.
        continueWatchingProvider
            .overrideWith((_) async => <ContinueWatchingItem>[]),
        titleTrailerProvider.overrideWith((_, __) async => null),
        pluginAccessProvider.overrideWith((_) => PluginAccess.available),
        ...extra,
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(
              width: size.width,
              height: size.height * 0.6,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  const movieItem = CatalogItemResponse(
    tmdbId: 27205,
    mediaType: 'movie',
    title: 'Inception',
    year: 2010,
    runtimeMinutes: 148,
    rating: 8.4,
    overview: 'A thief who steals corporate secrets through dreams.',
  );

  const tvItem = CatalogItemResponse(
    tmdbId: 1396,
    mediaType: 'tv',
    title: 'Breaking Bad',
    year: 2008,
    rating: 9.5,
    seasonsCount: 5,
    overview: 'A chemistry teacher turns to making meth.',
  );

  testWidgets('renders title + Guarda CTA for movie', (t) async {
    await t.pumpWidget(host(TitleHero(item: movieItem, onShare: () {})));
    await t.pumpAndSettle();
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('▶ Guarda'), findsOneWidget);
    expect(find.text('＋ La mia lista'), findsOneWidget);
    // No trailer overridden → no 🔊 toggle.
    expect(find.byIcon(Icons.volume_off), findsNothing);
  });

  testWidgets('tv title shows Guarda S1 E1 when no progress', (t) async {
    await t.pumpWidget(host(TitleHero(item: tvItem, onShare: () {})));
    await t.pumpAndSettle();
    expect(find.text('▶ Guarda S1 E1'), findsOneWidget);
  });

  testWidgets('tv title shows Riprendi when continue-watching has it',
      (t) async {
    await t.pumpWidget(host(
      TitleHero(item: tvItem, onShare: () {}),
      extra: [
        continueWatchingProvider.overrideWith((_) async => [
              const ContinueWatchingItem(
                tmdbId: 1396,
                mediaType: 'tv',
                title: 'Breaking Bad',
                seasonNumber: 2,
                episodeNumber: 3,
                positionSeconds: 600,
                durationSeconds: 2700,
              ),
            ]),
      ],
    ));
    await t.pumpAndSettle();
    expect(find.text('▶ Riprendi'), findsOneWidget);
  });

  testWidgets('share icon copies deep link to clipboard', (t) async {
    final messenger = TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger;
    String? copied;
    messenger.setMockMethodCallHandler(SystemChannels.platform,
        (call) async {
      if (call.method == 'Clipboard.setData') {
        final args = call.arguments as Map<dynamic, dynamic>;
        copied = args['text'] as String?;
      }
      return null;
    });

    var sharedCount = 0;
    await t.pumpWidget(host(TitleHero(
      item: movieItem,
      onShare: () {
        sharedCount += 1;
        Clipboard.setData(const ClipboardData(
          text: 'streamload://title/27205?media_type=movie',
        ));
      },
    )));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.ios_share));
    await t.pumpAndSettle();
    expect(sharedCount, 1);
    expect(copied, 'streamload://title/27205?media_type=movie');

    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('toggle La mia lista flips to ✓ Nella lista', (t) async {
    final fav = _FavApiMock();
    when(fav.list).thenAnswer((_) async => <Map<String, dynamic>>[]);
    when(() => fav.add(27205, 'movie')).thenAnswer((_) async {});
    await t.pumpWidget(host(
      TitleHero(item: movieItem, onShare: () {}),
      extra: [favoritesApiProvider.overrideWith((_) async => fav)],
    ));
    await t.pumpAndSettle();
    expect(find.text('＋ La mia lista'), findsOneWidget);
    await t.tap(find.text('＋ La mia lista'));
    await t.pumpAndSettle();
    expect(find.text('✓ Nella lista'), findsOneWidget);
    verify(() => fav.add(27205, 'movie')).called(1);
  });
}
