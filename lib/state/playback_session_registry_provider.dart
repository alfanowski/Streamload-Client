// lib/state/playback_session_registry_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../player/session.dart';

/// App-wide singleton [PlaybackSessionRegistry]. Holds all active playback
/// sessions keyed by their random hex ID. Sessions expire after 4 hours of
/// inactivity (TTL is reset on every proxy hit).
final playbackSessionRegistryProvider = Provider<PlaybackSessionRegistry>((ref) {
  return PlaybackSessionRegistry(ttl: const Duration(hours: 4));
});
