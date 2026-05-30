// lib/presentation/widgets/cast/cast_card.dart
//
// Pass 3 CAST-3 — circular actor portrait + Fraunces italic name +
// dimmed mono character role. Tap routes to /person/<tmdbId>. Editorial
// pivot: the round avatar is the IMDb / Prime Video standard for face
// shots — the "no circular" rule from CM-1 applies to title cards, not
// people. PressFeedback gives the now-quiet 110 ms ease-out squeeze.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../responsive.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../press_feedback.dart';

/// Minimal data the row needs per actor. Pulled out as a value type so
/// title pages can map `CatalogCreditPerson` → `CastCardData` without
/// dragging the whole credits model into the widget API.
class CastCardData {
  const CastCardData({
    required this.tmdbId,
    required this.name,
    this.character,
    this.profileUrl,
  });

  final int tmdbId;
  final String name;
  final String? character;
  final String? profileUrl;
}

class CastCard extends StatelessWidget {
  const CastCard({super.key, required this.data});

  final CastCardData data;

  // Bigger, cleaner cast cards — generous circular avatars with a crisp
  // name + role beneath.
  static const double _radiusDesktop = 52;
  static const double _radiusTabletPhone = 44;
  static const double _widthDesktop = 116;
  static const double _widthTablet = 104;
  static const double _widthPhone = 96;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final radius = Responsive.isDesktop(context)
        ? _radiusDesktop
        : _radiusTabletPhone;
    final width = isPhone
        ? _widthPhone
        : isTablet
            ? _widthTablet
            : _widthDesktop;

    return PressFeedback(
      child: InkWell(
        onTap: () => context.go('/person/${data.tmdbId}'),
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatar(radius: radius, profileUrl: data.profileUrl),
              const SizedBox(height: 12),
              Text(
                data.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: StreamloadTypography.v3Body(
                  fontSize: 14,
                  color: StreamloadColors.v3TextPrimary,
                ).copyWith(fontWeight: FontWeight.w600, height: 1.2),
              ),
              if (data.character != null && data.character!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    data.character!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: StreamloadTypography.v3Body(
                      fontSize: 12,
                      color: StreamloadColors.v3TextMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      // Hairline warm border at 8% — same border discipline as PosterCard
      // and the v3 sidebar dividers. Reads as "edge", not "frame".
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

/// Warm gradient fallback when TMDB has no profile_path for the person.
/// Keeps the row's rhythm without leaving an awkward empty disc.
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
          size: 22,
        ),
      ),
    );
  }
}
