// lib/presentation/view_models/media_card_vm.dart
//
// Null-safe presentation model for a poster/backdrop card. Widgets never see
// a raw nullable field: missing poster -> null (media shows initials), blank
// title -> placeholder, missing year -> simply absent from the meta line.
// This is the robustness rule "widgets never render raw nulls" in code.
import '../../domain/models/media_summary.dart';

class MediaCardVm {
  const MediaCardVm({
    required this.tmdbId,
    required this.mediaType,
    required this.title,
    required this.posterUrl,
    required this.metaLine,
  });

  final int tmdbId;
  final String mediaType;
  final String title;

  /// Null when the source had no usable poster — AspectRatioMedia then
  /// renders its initials fallback instead of a broken image.
  final String? posterUrl;

  /// Pre-formatted "1999 · Film" style line, already stripped of empties.
  final String metaLine;

  factory MediaCardVm.fromSummary(MediaSummary s) {
    final trimmedTitle = s.title.trim();
    final poster = s.posterUrl;
    return MediaCardVm(
      tmdbId: s.tmdbId,
      mediaType: s.mediaType,
      title: trimmedTitle.isEmpty ? 'Senza titolo' : trimmedTitle,
      posterUrl: (poster == null || poster.isEmpty) ? null : poster,
      metaLine: buildMetaLine([
        if (s.year != null) s.year.toString(),
        mediaTypeLabel(s.mediaType),
      ]),
    );
  }

  static String mediaTypeLabel(String type) {
    switch (type) {
      case 'movie':
        return 'Film';
      case 'tv':
        return 'Serie';
      case 'anime':
        return 'Anime';
      default:
        return '';
    }
  }

  static String buildMetaLine(List<String> parts) =>
      parts.where((p) => p.trim().isNotEmpty).join(' · ');
}
