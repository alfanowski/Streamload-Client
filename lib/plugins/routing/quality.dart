// lib/plugins/routing/quality.dart
//
// Pure scoring function for a plugin-returned StreamBundle. Higher is better.
// Future enrichments (resolution probe, codec, audio tracks) hook in here.
// For v1 the only filter is DRM: zero score for any bundle marked drm=true
// because the player cannot decrypt Widevine without a CDM.

/// Score [bundle] (the Map returned by plugin.getStreams) from 0 upward.
/// A score of 0 means "do not select".
int scoreBundle(Map<String, dynamic> bundle) {
  if (bundle['is_drm'] == true) return 0;
  if (bundle['manifest_url'] is! String ||
      (bundle['manifest_url'] as String).isEmpty) {
    return 0;
  }
  return 50;
}
