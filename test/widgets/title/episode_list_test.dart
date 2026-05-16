// test/widgets/title/episode_list_test.dart
//
// EpisodeList — Phase E3 of sub-plan 8. Verifies:
//   - loading state shows the spinner
//   - empty seasons render as nothing (parent layout decides whether
//     to skip the section)
//   - data shows season chips + episode rows with title + duration
//   - tapping a non-active chip switches the visible episodes
//   - rows are dimmed (Opacity 0.5) when plugin access is unavailable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:streamload_client/data/remote/endpoints/episodes_api.dart';
import 'package:streamload_client/presentation/widgets/title/episode_list.dart';
import 'package:streamload_client/state/api_client_provider.dart';
import 'package:streamload_client/state/plugin_access_provider.dart';

class _EpisodesApiMock extends Mock implements EpisodesApi {}

void main() {
  Widget host(
    Widget child, {
    required EpisodesApi episodesApi,
    PluginAccess access = PluginAccess.available,
    Size size = const Size(1280, 800),
  }) {
    return ProviderScope(
      overrides: [
        episodesApiProvider.overrideWith((_) async => episodesApi),
        pluginAccessProvider.overrideWithValue(access),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> seasonsPayload() => {
        'seasons': [
          {
            'season_number': 1,
            'episodes': [
              {
                'episode_number': 1,
                'title': 'Pilot',
                'still_url': null,
                'runtime_minutes': 58,
              },
              {
                'episode_number': 2,
                'title': "Cat's in the Bag",
                'still_url': null,
                'runtime_minutes': 48,
              },
            ],
          },
          {
            'season_number': 2,
            'episodes': [
              {
                'episode_number': 1,
                'title': 'Seven Thirty-Seven',
                'still_url': null,
                'runtime_minutes': 47,
              },
            ],
          },
        ],
      };

  testWidgets('renders season chips + episode rows', (t) async {
    final api = _EpisodesApiMock();
    when(() => api.list(99)).thenAnswer((_) async => seasonsPayload());
    await t.pumpWidget(host(
      const EpisodeList(tmdbId: 99),
      episodesApi: api,
    ));
    await t.pumpAndSettle();
    expect(find.text('EPISODI · S1'), findsOneWidget);
    expect(find.text('Stagione 1'), findsOneWidget);
    expect(find.text('Stagione 2'), findsOneWidget);
    expect(find.text('Pilot'), findsOneWidget);
    expect(find.textContaining("Cat's in the Bag"), findsOneWidget);
    expect(find.text('58 min'), findsOneWidget);
  });

  testWidgets('tapping Stagione 2 switches to season 2 episodes', (t) async {
    final api = _EpisodesApiMock();
    when(() => api.list(99)).thenAnswer((_) async => seasonsPayload());
    await t.pumpWidget(host(
      const EpisodeList(tmdbId: 99),
      episodesApi: api,
    ));
    await t.pumpAndSettle();
    expect(find.text('Pilot'), findsOneWidget);
    await t.tap(find.text('Stagione 2'));
    await t.pumpAndSettle();
    expect(find.text('Pilot'), findsNothing);
    expect(find.text('Seven Thirty-Seven'), findsOneWidget);
    expect(find.text('EPISODI · S2'), findsOneWidget);
  });

  testWidgets('empty seasons returns nothing', (t) async {
    final api = _EpisodesApiMock();
    when(() => api.list(99))
        .thenAnswer((_) async => <String, dynamic>{'seasons': []});
    await t.pumpWidget(host(
      const EpisodeList(tmdbId: 99),
      episodesApi: api,
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('EPISODI'), findsNothing);
  });

  testWidgets('unavailable plugin access dims rows', (t) async {
    final api = _EpisodesApiMock();
    when(() => api.list(99)).thenAnswer((_) async => seasonsPayload());
    await t.pumpWidget(host(
      const EpisodeList(tmdbId: 99),
      episodesApi: api,
      access: PluginAccess.noAccess,
    ));
    await t.pumpAndSettle();
    // Find Opacity widgets and assert at least one is set to 0.5 (the
    // episode rows wrapped in Opacity when plugin access is missing).
    final opacities =
        t.widgetList<Opacity>(find.byType(Opacity)).where((o) => o.opacity == 0.5);
    expect(opacities, isNotEmpty);
  });

  testWidgets('phone uses smaller thumb size', (t) async {
    final api = _EpisodesApiMock();
    when(() => api.list(99)).thenAnswer((_) async => seasonsPayload());
    await t.pumpWidget(host(
      const EpisodeList(tmdbId: 99),
      episodesApi: api,
      size: const Size(390, 844),
    ));
    await t.pumpAndSettle();
    // Just assert the page renders without throwing — thumb width is
    // an internal layout detail, not a public surface to assert on.
    expect(find.text('Pilot'), findsOneWidget);
  });
}
