// lib/state/availability_provider.dart
//
// availabilityProvider — Phase F2 of sub-plan 8.
//
// Drives the title-page "Guarda" CTA's three states (checking / play /
// unavailable). Resolves the TMDB hint via the existing PlayController.
// resolveTitle, then delegates to ProviderRouter.probeAvailability which
// does the search+match fan-out + 30-min in-memory cache.
//
// autoDispose — the title page is the only consumer for now, and the
// underlying cache lives on the non-autoDispose ProviderRouter so it
// survives this provider's lifecycle. Re-entering the same title page
// produces a fresh subscription but the probe result is already cached.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'play_controller_provider.dart';

/// Identity tuple for an availability probe — used as the `.family`
/// argument so Riverpod dedups concurrent requests for the same title
/// (and the same TV episode, if specified).
class AvailabilityKey {
  const AvailabilityKey({
    required this.tmdbId,
    required this.mediaType,
    this.season,
    this.episode,
  });

  final int tmdbId;
  final String mediaType;
  final int? season;
  final int? episode;

  @override
  bool operator ==(Object other) =>
      other is AvailabilityKey &&
      other.tmdbId == tmdbId &&
      other.mediaType == mediaType &&
      other.season == season &&
      other.episode == episode;

  @override
  int get hashCode => Object.hash(tmdbId, mediaType, season, episode);

  @override
  String toString() =>
      'AvailabilityKey($tmdbId, $mediaType, s=$season, e=$episode)';
}

/// True iff some installed plugin can resolve this title to a candidate
/// entry (router search + tiered matcher). Used by the title page Guarda
/// CTA to swap to "Al momento non disponibile" when nothing matches.
///
/// Flow: PlayController.resolveTitle (tmdbId → TitleHint) →
/// ProviderRouter.probeAvailability (fan-out, 4 s deadline, 30 min cache).
final availabilityProvider =
    FutureProvider.autoDispose.family<bool, AvailabilityKey>((ref, key) async {
  final controller = await ref.watch(playControllerProvider.future);
  final hint = await controller.resolveTitle(key.tmdbId, key.mediaType);
  return controller.router.probeAvailability(
    mediaType: key.mediaType,
    hint: hint,
    season: key.season,
    episode: key.episode,
  );
});
