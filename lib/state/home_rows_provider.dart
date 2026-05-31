// lib/state/home_rows_provider.dart
//
// Riverpod providers that feed the Home page rows (sub-plan 8, Phase D2).
// Every row is a separate autoDispose FutureProvider so a slow / failing
// row doesn't block the rest of the page — each Consumer in HomePage
// renders its own loading / error placeholder.
//
// Compound rows ("Nuove uscite movie ∪ tv", "Top di sempre movie ∪ tv")
// fetch both halves in parallel via Future.wait and concat them. They
// stay autoDispose so the in-memory cache evicts when the user leaves
// Home — refreshes hit TMDB again, which is fine given the 40 req/sec
// budget.
//
// heroSlidesProvider composes the trendingWeek result with per-title
// videos calls so HeroCarousel can autoplay trailers. We use a tiny
// per-session cache keyed by (tmdbId, mediaType) so successive opens of
// Home in the same session don't repeat the videos lookups.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/catalog_credits.dart';
import '../domain/models/media_summary.dart';
import '../presentation/widgets/hero/hero_carousel.dart';
import 'api_client_provider.dart';
import 'favorites_provider.dart';
import 'title_provider.dart';
import 'watchlist_provider.dart';

// ──────────────────────────────────────────────────────────────────────────
// Row keys — small value-types used as `.family` arguments. They must
// override == / hashCode so riverpod can dedupe requests.
// ──────────────────────────────────────────────────────────────────────────

/// Argument for the by-genre family — list of TMDB genre IDs plus the
/// media_type they apply to (movie or tv). Optional originalLanguage for
/// rows like "Commedie italiane" (filter to `it`).
class GenreRowKey {
  const GenreRowKey({
    required this.genreIds,
    required this.mediaType,
    this.originalLanguage,
  });

  final List<int> genreIds;
  final String mediaType;
  final String? originalLanguage;

  @override
  bool operator ==(Object other) {
    if (other is! GenreRowKey) return false;
    if (other.mediaType != mediaType) return false;
    if (other.originalLanguage != originalLanguage) return false;
    if (other.genreIds.length != genreIds.length) return false;
    for (var i = 0; i < genreIds.length; i++) {
      if (other.genreIds[i] != genreIds[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        mediaType,
        originalLanguage,
        Object.hashAll(genreIds),
      );
}

/// Argument for the similar / recommendations families.
class TmdbKey {
  const TmdbKey({required this.tmdbId, required this.mediaType});

  final int tmdbId;
  final String mediaType;

  @override
  bool operator ==(Object other) =>
      other is TmdbKey &&
      other.tmdbId == tmdbId &&
      other.mediaType == mediaType;

  @override
  int get hashCode => Object.hash(tmdbId, mediaType);
}

// ──────────────────────────────────────────────────────────────────────────
// Row providers
// ──────────────────────────────────────────────────────────────────────────

/// Retry a catalog fetch a few times with backoff. At cold start the API
/// client / session can still be settling, so the FIRST request occasionally
/// fails — without this the hero ("in evidenza") and search "Suggeriti" would
/// just stay empty until a manual retry.
Future<T> _retry<T>(Future<T> Function() op, {int attempts = 3}) async {
  Object lastError = StateError('retry failed');
  for (var i = 0; i < attempts; i++) {
    try {
      return await op();
    } catch (e) {
      lastError = e;
      if (i < attempts - 1) {
        await Future<void>.delayed(Duration(milliseconds: 350 * (i + 1)));
      }
    }
  }
  throw lastError;
}

final trendingDayProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return _retry(() => api.trending(period: 'day'));
});

final trendingWeekProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return _retry(() => api.trending(period: 'week'));
});

/// Trending today, narrowed to movies — feeds the /film page top row.
/// Kept as a dedicated provider (rather than calling `trending('day',
/// 'movie')` inline) so successive Home opens reuse the same cached
/// future and ParameterizedFamily key invalidation works cleanly.
final trendingDayMoviesProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.trending(period: 'day', mediaType: 'movie');
});

/// Trending today, narrowed to TV — feeds the /serie + /anime pages.
final trendingDayTvProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.trending(period: 'day', mediaType: 'tv');
});

final newReleasesProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, String>((ref, mediaType) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.newReleases(mediaType: mediaType);
});

final byGenreProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, GenreRowKey>((ref, key) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.byGenre(
    genreIds: key.genreIds,
    mediaType: key.mediaType,
    originalLanguage: key.originalLanguage,
  );
});

final topRatedProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, String>((ref, mediaType) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.topRated(mediaType: mediaType);
});

final similarProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, TmdbKey>((ref, key) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.similar(tmdbId: key.tmdbId, mediaType: key.mediaType);
});

final recommendationsProvider = FutureProvider.autoDispose
    .family<List<MediaSummary>, TmdbKey>((ref, key) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  return api.recommendations(tmdbId: key.tmdbId, mediaType: key.mediaType);
});

/// Cast + crew for the title page sidebar (Phase E2). Returns an empty
/// [CatalogCredits] if the backend itself returned no data — keeps the
/// sidebar quiet rather than surfacing an error for missing titles.
final creditsProvider = FutureProvider.autoDispose
    .family<CatalogCredits, TmdbKey>((ref, key) async {
  final api = await ref.watch(catalogApiProvider.future);
  try {
    return await api.credits(key.tmdbId, mediaType: key.mediaType);
  } catch (_) {
    return const CatalogCredits();
  }
});

/// Official TMDB title logo (transparent PNG wordmark) for a single title —
/// the title page hero shows it instead of typeset text, like the Home hero.
final titleLogoProvider = FutureProvider.autoDispose
    .family<String?, TmdbKey>((ref, key) async {
  final api = await ref.watch(catalogApiProvider.future);
  try {
    return await api.logo(key.tmdbId, mediaType: key.mediaType);
  } catch (_) {
    return null;
  }
});

// ──────────────────────────────────────────────────────────────────────────
// Aggregations used by Home for compound rows.
// ──────────────────────────────────────────────────────────────────────────

/// Movies ∪ TV "new releases", concatenated and capped at 20 items. The
/// backend doesn't expose a unified endpoint because the date fields
/// differ (primary_release_date vs first_air_date) so we fetch both halves
/// in parallel and merge here.
final newReleasesAllProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  final results = await Future.wait([
    api.newReleases(mediaType: 'movie'),
    api.newReleases(mediaType: 'tv'),
  ]);
  final combined = <MediaSummary>[...results[0], ...results[1]];
  // Backend already sorts each half by date desc; we interleave and cap.
  return combined.take(40).toList(growable: false);
});

/// Top rated movies ∪ TV.
final topRatedAllProvider =
    FutureProvider.autoDispose<List<MediaSummary>>((ref) async {
  final api = await ref.watch(catalogRowsApiProvider.future);
  final results = await Future.wait([
    api.topRated(mediaType: 'movie'),
    api.topRated(mediaType: 'tv'),
  ]);
  final combined = <MediaSummary>[...results[0], ...results[1]];
  return combined.take(40).toList(growable: false);
});

// ──────────────────────────────────────────────────────────────────────────
// Videos cache — used by heroSlidesProvider to pick a YouTube trailer
// key per title. We keep a per-session map so reopening Home doesn't
// repeat the same 5 videos calls. Cleared when the app process exits.
//
// The cache lives in a Provider (not autoDispose) so its lifetime is the
// app session, not the Home page mount.
// ──────────────────────────────────────────────────────────────────────────

class _VideosCache {
  final Map<TmdbKey, Future<String?>> _futures = {};

  Future<String?> get(Ref ref, TmdbKey key) {
    final hit = _futures[key];
    if (hit != null) return hit;
    final fut = _fetch(ref, key);
    _futures[key] = fut;
    return fut;
  }

  Future<String?> _fetch(Ref ref, TmdbKey key) async {
    final api = await ref.read(catalogApiProvider.future);
    try {
      final videos = await api.videos(key.tmdbId, mediaType: key.mediaType);
      if (videos.isEmpty) return null;
      // Prefer official trailers; fall back to any trailer / teaser; else
      // first YouTube video.
      final official = _firstWhereOrNull(
        videos,
        (v) => v.official && v.type == 'Trailer',
      );
      if (official != null) return official.key;
      final teaser = _firstWhereOrNull(
        videos,
        (v) => v.official && v.type == 'Teaser',
      );
      if (teaser != null) return teaser.key;
      final anyTrailer = _firstWhereOrNull(
        videos,
        (v) => v.type == 'Trailer' || v.type == 'Teaser',
      );
      if (anyTrailer != null) return anyTrailer.key;
      return videos.first.key;
    } catch (_) {
      // A single missing trailer shouldn't break the carousel; the slide
      // just falls back to a static backdrop image.
      return null;
    }
  }
}

E? _firstWhereOrNull<E>(Iterable<E> source, bool Function(E) test) {
  for (final e in source) {
    if (test(e)) return e;
  }
  return null;
}

final _videosCacheProvider = Provider<_VideosCache>((_) => _VideosCache());

/// Per-session cache of official title-logo URLs (TMDB image treatment),
/// keyed by title — same lifetime/shape as [_VideosCache]. A null result
/// means "no logo art; render the text title".
class _LogosCache {
  final Map<TmdbKey, Future<String?>> _futures = {};

  Future<String?> get(Ref ref, TmdbKey key) {
    final hit = _futures[key];
    if (hit != null) return hit;
    final fut = _fetch(ref, key);
    _futures[key] = fut;
    return fut;
  }

  Future<String?> _fetch(Ref ref, TmdbKey key) async {
    final api = await ref.read(catalogApiProvider.future);
    try {
      return await api.logo(key.tmdbId, mediaType: key.mediaType);
    } catch (_) {
      // Missing logo art must never break the hero — fall back to text.
      return null;
    }
  }
}

final _logosCacheProvider = Provider<_LogosCache>((_) => _LogosCache());

/// Returns the best-pick YouTube trailer key for a given title, or null
/// when no playable trailer is available. Backed by the same per-session
/// cache HeroCarousel uses, so opening a title page after seeing it on
/// Home doesn't repeat the TMDB videos call.
///
/// Used by the Title page hero (Phase E1) to drive HeroBackdrop's
/// videoId — when null the hero falls back to the static backdrop.
final titleTrailerProvider =
    FutureProvider.autoDispose.family<String?, TmdbKey>((ref, key) async {
  final cache = ref.read(_videosCacheProvider);
  return cache.get(ref, key);
});

/// Composes HeroCarousel input from trending-week + per-title trailer.
///
/// Picks the top 5 of the weekly trending row, fetches videos for each in
/// parallel (cached for the session), and assembles HeroSlideData entries
/// with onPlay (navigates to title page) + onAdd (toggles favorites).
///
/// onPlay / onAdd are bound to the BuildContext-free path; the
/// HomePage wraps them so navigation uses the page's GoRouter context.
/// We pass back a tuple via heroSlidesProvider (raw data) and HomePage
/// supplies the callbacks at render time.
final heroSlidesProvider =
    FutureProvider.autoDispose<List<HeroSlideData>>((ref) async {
  // Use trending-of-the-DAY so the hero rotates fresh titles instead of the
  // same stable weekly top-5.
  final trending = await ref.watch(trendingDayProvider.future);
  if (trending.isEmpty) return const <HeroSlideData>[];
  final top = trending.take(5).toList(growable: false);
  final cache = ref.read(_videosCacheProvider);
  final logosCache = ref.read(_logosCacheProvider);
  final keys = top
      .map((m) => TmdbKey(tmdbId: m.tmdbId, mediaType: m.mediaType))
      .toList(growable: false);
  final videoKeys = await Future.wait(
    keys.map((k) => cache.get(ref, k)),
  );
  // Official title logos (transparent PNG) in parallel — the hero renders
  // these instead of typeset text when present.
  final logoUrls = await Future.wait(
    keys.map((k) => logosCache.get(ref, k)),
  );
  final slides = <HeroSlideData>[];
  for (var i = 0; i < top.length; i++) {
    final m = top[i];
    slides.add(HeroSlideData(
      title: m.title,
      mediaType: m.mediaType,
      tmdbId: m.tmdbId,
      year: m.year,
      synopsis: null, // trending row doesn't carry overview; spec says
      // synopsis is optional — Phase E will fetch full details for the
      // Title page hero. Home hero stays terse.
      backdropUrl: m.backdropUrl,
      // Pass the poster so HeroBackdrop can fall back to it when the
      // title has no backdrop image — without it the operator saw a
      // solid black hero behind the title text. (P1 fix.)
      posterUrl: m.posterUrl,
      videoId: videoKeys[i],
      titleLogoUrl: logoUrls[i],
    ));
  }
  return slides;
});

// ──────────────────────────────────────────────────────────────────────────
// "La mia lista" composition: favorites ∪ watchlist deduped by tmdbId.
// We resolve TitleKey -> MediaSummary via the local catalog cache (drift
// upserted on titleProvider hits) — kept light: we don't refetch every
// title on Home open. Items the user has never opened a title page for
// fall back to a placeholder MediaSummary with just the tmdbId / title.
//
// Implementation lives in HomePage (Phase D5) because it needs DB access
// and the row is essentially a UI concern. We expose the deduped set
// here as TitleKey list for convenience.
// ──────────────────────────────────────────────────────────────────────────

/// Helper: merge favorites + watchlist into a dedup-by-tmdbId list of
/// TitleKey. Watches both providers so the row recomposes when either
/// changes.
final myListKeysProvider = Provider.autoDispose<List<TitleKey>>((ref) {
  final fav = ref.watch(favoritesProvider).value ?? const <TitleKey>{};
  final wl = ref.watch(watchlistProvider).value ?? const <TitleKey>{};
  final seen = <int>{};
  final out = <TitleKey>[];
  for (final k in [...fav, ...wl]) {
    if (seen.add(k.tmdbId)) out.add(k);
  }
  return out;
});

