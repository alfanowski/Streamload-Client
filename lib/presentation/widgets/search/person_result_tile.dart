// lib/presentation/widgets/search/person_result_tile.dart
//
// PS-3 — a person (actor / director / writer / producer) result row for
// search. Horizontal layout: circular avatar (same warm-fallback
// treatment as CastCard) + Fraunces italic name + a mono department label
// + the dimmed "known for" titles. Tap routes to /person/<id>.
//
// Cinema Magazine discipline: reuses display() Fraunces, v3LabelMono /
// v3MetaMono, the CastCard avatar look, and PressFeedback. No new accent
// colors, no glass, no loud motion.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/search_results.dart';
import '../../theme/colors.dart';
import '../../theme/spacing.dart';
import '../../theme/typography.dart';
import '../press_feedback.dart';

class PersonResultTile extends StatelessWidget {
  const PersonResultTile({super.key, required this.person, this.onTap});

  final SearchPersonResult person;

  /// Optional tap override. Defaults to `context.go('/person/<id>')`.
  /// The search overlay passes a handler that ALSO pops the overlay
  /// before navigating.
  final VoidCallback? onTap;

  static const double _avatarRadius = 28;

  @override
  Widget build(BuildContext context) {
    final department = _departmentLabel(person.department);
    final knownFor = person.knownFor.join(' · ');

    return PressFeedback(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () => context.go('/person/${person.tmdbId}'),
          borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _Avatar(radius: _avatarRadius, profileUrl: person.profileUrl),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: StreamloadTypography.display(
                            fontSize: 18,
                            italic: true,
                            color: StreamloadColors.v3TextPrimary,
                          ),
                        ),
                        if (department != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            department,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StreamloadTypography.v3LabelMono(
                              color: StreamloadColors.v3TextSecondary,
                            ),
                          ),
                        ],
                        if (knownFor.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            knownFor,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StreamloadTypography.v3MetaMono(
                              fontSize: 11,
                              color: StreamloadColors.v3TextMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// TMDB departments → Italian labels. Unknown / null → null (the row
  /// just omits the line).
  static String? _departmentLabel(String? department) {
    switch (department) {
      case 'Acting':
        return 'Interprete';
      case 'Directing':
        return 'Regia';
      case 'Writing':
        return 'Sceneggiatura';
      case 'Production':
        return 'Produzione';
      default:
        return null;
    }
  }
}

/// Circular avatar — same warm hairline border + gradient fallback as
/// CastCard's `_Avatar`, scaled for the search row.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.radius, required this.profileUrl});

  final double radius;
  final String? profileUrl;

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: StreamloadColors.v3BorderGlass,
          width: 1,
        ),
      ),
      child: ClipOval(
        child: profileUrl != null
            ? CachedNetworkImage(
                imageUrl: profileUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: StreamloadColors.v3SurfaceGlass),
                errorWidget: (_, __, ___) => const _PortraitFallback(),
              )
            : const _PortraitFallback(),
      ),
    );
  }
}

class _PortraitFallback extends StatelessWidget {
  const _PortraitFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StreamloadColors.v3SurfaceGlassHi,
            StreamloadColors.v3SurfaceGlass,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          color: StreamloadColors.v3TextMuted,
          size: 20,
        ),
      ),
    );
  }
}
