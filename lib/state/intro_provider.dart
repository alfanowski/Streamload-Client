// lib/state/intro_provider.dart
//
// Skip-intro / next-episode markers for a TV season. The backend
// (GET /api/intro/{tmdb_id}/s{season}) returns auto-detected markers:
//   { "intro_start": int, "intro_end": int, "outro_start": int | null }
// all in seconds. 204 → no marker for this title/season (null).
//
// Markers are per-SEASON (the opening titles are assumed consistent across
// the season) and best-effort — many titles won't have them, so every
// consumer must treat a null marker as "feature unavailable", not an error.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client_provider.dart';

class IntroMarker {
  const IntroMarker({
    required this.introStart,
    required this.introEnd,
    this.outroStart,
  });

  /// Seconds. The intro ("sigla") window is [introStart, introEnd].
  final int introStart;
  final int introEnd;

  /// Seconds. Where the end credits begin — the cue for the "Prossimo
  /// episodio" card. Null when the backend couldn't detect it.
  final int? outroStart;

  Duration get introStartD => Duration(seconds: introStart);
  Duration get introEndD => Duration(seconds: introEnd);
  Duration? get outroStartD =>
      outroStart == null ? null : Duration(seconds: outroStart!);

  factory IntroMarker.fromJson(Map<String, dynamic> json) => IntroMarker(
        introStart: (json['intro_start'] as num).toInt(),
        introEnd: (json['intro_end'] as num).toInt(),
        outroStart: (json['outro_start'] as num?)?.toInt(),
      );
}

/// Marker for a given (tmdbId, season). Null when the title/season has none.
final introMarkerProvider =
    FutureProvider.family<IntroMarker?, ({int tmdbId, int season})>(
        (ref, key) async {
  final api = await ref.watch(introApiProvider.future);
  final raw = await api.get(key.tmdbId, key.season);
  if (raw == null) return null;
  return IntroMarker.fromJson(raw);
});
