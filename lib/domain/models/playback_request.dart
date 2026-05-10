// lib/domain/models/playback_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'playback_request.freezed.dart';

@freezed
class PlaybackRequest with _$PlaybackRequest {
  const factory PlaybackRequest({
    required int tmdbId,
    required String mediaType,
    int? season,
    int? episode,
  }) = _PlaybackRequest;
}
