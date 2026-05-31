// lib/presentation/pages/person_page.dart
//
// Actor / director page — a full-screen, Netflix-style MODAL built exactly
// like the title page: a cinematic hero (the portrait, full-bleed, fading to
// black) that ZOOMS on a downward overscroll, a glass ✕ + pull-to-dismiss,
// then an expandable biography and the popularity-sorted filmography as a
// 3-column covers grid. Opens FROM the tapped cast avatar via a shared Hero.
//
// State:
//   - personProvider(tmdbId) → Person bio/identity
//   - personCreditsProvider(tmdbId) → List<MediaSummary> filmography
// Both autoDispose. Tap a filmography card → /title/<id> (opens from poster).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/person.dart';
import '../../state/person_provider.dart';
import '../responsive.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/hero/hero_backdrop.dart';
import '../widgets/modal/modal_shell.dart';
import '../widgets/modal/section_widgets.dart';
import '../widgets/modal/stretchy_hero_scroll_view.dart';
import '../widgets/poster_card.dart';

class PersonPage extends ConsumerWidget {
  const PersonPage({super.key, required this.tmdbId, this.heroTag});

  final int tmdbId;

  /// Shared-element tag of the avatar the user tapped — the hero opens FROM
  /// that avatar (and back to it on close). Null → plain fade.
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personProvider(tmdbId));
    return ModalShell(
      child: personAsync.when(
        loading: () => const _Skeleton(),
        error: (e, _) => _ErrorState(
          message: '$e',
          onRetry: () => ref.invalidate(personProvider(tmdbId)),
        ),
        data: (person) => _PersonContent(person: person, heroTag: heroTag),
      ),
    );
  }
}

class _PersonContent extends ConsumerWidget {
  const _PersonContent({required this.person, this.heroTag});
  final Person person;
  final Object? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhone = Responsive.isPhone(context);
    final pad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : StreamloadSpacing.pagePaddingDesktop;
    final heroHeight = MediaQuery.sizeOf(context).height * (isPhone ? 0.6 : 0.7);
    final creditsAsync = ref.watch(personCreditsProvider(person.tmdbId));

    final hasBio = (person.biography ?? '').isNotEmpty;
    final aka = person.alsoKnownAs.isNotEmpty
        ? person.alsoKnownAs.take(4).join(' · ')
        : null;

    return StretchyHeroScrollView(
      heroHeight: heroHeight,
      hero: _PersonHero(person: person, heroTag: heroTag),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 18),
            if (hasBio) ...[
              Padding(padding: pad, child: ExpandableText(person.biography!)),
              const SizedBox(height: 18),
            ],
            if (aka != null) ...[
              Padding(
                padding: pad,
                child: Text(
                  'Anche noto come · $aka',
                  style: StreamloadTypography.v3Body(
                    fontSize: 12.5,
                    color: StreamloadColors.v3TextMuted,
                  ),
                ),
              ),
              const SizedBox(height: 26),
            ] else if (hasBio)
              const SizedBox(height: 10),
            Padding(padding: pad, child: const SectionHeader('Filmografia')),
            const SizedBox(height: 16),
          ]),
        ),
        creditsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
            ),
          ),
          error: (_, __) => const SliverToBoxAdapter(child: _FilmographyEmpty()),
          data: (items) => items.isEmpty
              ? const SliverToBoxAdapter(child: _FilmographyEmpty())
              : SliverPadding(
                  padding: pad,
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2 / 3,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final m = items[i];
                        final tag = 'pf_${m.tmdbId}_$i';
                        return PosterCard(
                          summary: m,
                          width: 120,
                          showLabel: false,
                          heroTag: tag,
                          onTap: () => context.push(
                            '/title/${m.tmdbId}?media_type=${m.mediaType}',
                            extra: tag,
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 56)),
      ],
    );
  }
}

// ── Hero ───────────────────────────────────────────────────────────────────

class _PersonHero extends StatelessWidget {
  const _PersonHero({required this.person, this.heroTag});
  final Person person;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final hPad = isPhone ? 16.0 : 64.0;
    final nameSize = isPhone ? 40.0 : (isTablet ? 52.0 : 64.0);

    final eyebrow = _italianDepartment(person.knownForDepartment);
    final birthLine = _formatBirthLine(person);

    // Full-bleed portrait as the hero backdrop, fading to black — same chrome
    // as the title hero. Aligned to the top so faces (usually upper-frame)
    // stay visible when the wide hero crops the 2:3 portrait.
    final backdrop = HeroBackdrop(backdropUrl: person.profileUrl);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (heroTag != null) Hero(tag: heroTag!, child: backdrop) else backdrop,
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, isPhone ? 24 : 56),
            child: Align(
              alignment:
                  isPhone ? Alignment.bottomCenter : Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isPhone ? 540 : 780),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isPhone
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    if (eyebrow != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(eyebrow,
                            style: StreamloadTypography.v3LabelMono()),
                      ),
                    Text(
                      person.name,
                      textAlign: isPhone ? TextAlign.center : TextAlign.start,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: StreamloadTypography.v3DisplayHero()
                          .copyWith(fontSize: nameSize),
                    ),
                    if (birthLine != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          birthLine,
                          textAlign:
                              isPhone ? TextAlign.center : TextAlign.start,
                          style: StreamloadTypography.v3Body(
                            fontSize: 13,
                            color: StreamloadColors.v3TextSecondary,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Maps TMDB's English department to the Italian eyebrow label.
String? _italianDepartment(String? dept) {
  if (dept == null || dept.isEmpty) return null;
  switch (dept) {
    case 'Acting':
      return 'INTERPRETE';
    case 'Directing':
      return 'REGIA';
    case 'Writing':
      return 'SCENEGGIATURA';
    case 'Production':
      return 'PRODUZIONE';
    default:
      return dept.toUpperCase();
  }
}

const _itMonths = [
  '', 'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// Returns null when there's no birthday to render. Handles the three shapes
/// TMDB sends: full ISO, year-only, and (rarely) day-only.
String? _formatBirthLine(Person p) {
  final birth = p.birthday;
  final death = p.deathday;
  String? leading;
  if (birth != null && birth.isNotEmpty) {
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = iso.firstMatch(birth);
    if (m != null) {
      final year = int.parse(m.group(1)!);
      final month = int.parse(m.group(2)!);
      final day = int.parse(m.group(3)!);
      final monthName = month >= 1 && month <= 12 ? _itMonths[month] : null;
      if (monthName != null) {
        leading = '$day $monthName $year';
        final place = p.placeOfBirth;
        if (place != null && place.isNotEmpty) {
          leading = '$leading · $place';
        }
      } else {
        leading = 'n. $year';
      }
    } else {
      final year = RegExp(r'^(\d{4})').firstMatch(birth)?.group(1);
      if (year != null) leading = 'n. $year';
    }
  }
  if (death != null && death.isNotEmpty) {
    final year = RegExp(r'^(\d{4})').firstMatch(death)?.group(1);
    if (year != null) {
      final dagger = ' – † $year';
      leading = leading == null ? '† $year' : '$leading$dagger';
    }
  }
  return leading;
}

// ── States ───────────────────────────────────────────────────────────────

class _FilmographyEmpty extends StatelessWidget {
  const _FilmographyEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Center(
        child: Text(
          'Nessun titolo disponibile',
          style: StreamloadTypography.v3Body(
            fontSize: 14,
            color: StreamloadColors.v3TextMuted,
          ),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('person-page-skeleton'),
      padding: const EdgeInsets.all(32),
      children: [
        Container(
          height: 360,
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius:
                BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
          ),
        ),
        const SizedBox(height: 28),
        const _SkelBar(widthFactor: 0.5, height: 28),
        const SizedBox(height: 16),
        const _SkelBar(widthFactor: 0.9, height: 14),
        const SizedBox(height: 8),
        const _SkelBar(widthFactor: 0.8, height: 14),
        const SizedBox(height: 40),
        const _SkelBar(widthFactor: 0.35, height: 22),
      ],
    );
  }
}

class _SkelBar extends StatelessWidget {
  const _SkelBar({required this.widthFactor, required this.height});
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: StreamloadColors.v3SurfaceGlass,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Errore di caricamento',
              style: StreamloadTypography.v3SectionHeader(),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: StreamloadTypography.v3Body(
                fontSize: 13,
                color: StreamloadColors.v3TextMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Riprova',
                style: StreamloadTypography.v3CtaLabel(
                  color: StreamloadColors.v3TextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
