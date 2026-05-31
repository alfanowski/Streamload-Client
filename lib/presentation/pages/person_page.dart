// lib/presentation/pages/person_page.dart
//
// Actor / director page — a full-screen, Netflix-style MODAL built exactly
// like the title page: a cinematic hero (the portrait, full-bleed, fading to
// black) that ZOOMS on a downward overscroll, a glass ✕ + pull-to-dismiss,
// an expandable biography, a structured "Info" block, and the filmography as
// a sortable 3-column covers grid (popular / newest / oldest) that loads the
// top 12 with a "Scopri di più" expander. Opens FROM the tapped cast avatar.
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
import '../widgets/press_feedback.dart';

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

class _PersonContent extends StatelessWidget {
  const _PersonContent({required this.person, this.heroTag});
  final Person person;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final pad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : StreamloadSpacing.pagePaddingDesktop;
    final heroHeight = MediaQuery.sizeOf(context).height * (isPhone ? 0.6 : 0.7);
    // No biography: TMDB bios are unreliable community/Wikipedia text. We show
    // only the structured Info facts + the filmography.
    final info = _PersonInfoBlock(person: person);

    return StretchyHeroScrollView(
      heroHeight: heroHeight,
      hero: _PersonHero(person: person, heroTag: heroTag),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 22),
            if (info.hasContent) ...[
              Padding(padding: pad, child: info),
              const SizedBox(height: 30),
            ],
            Padding(
              padding: pad,
              child: _FilmographySection(tmdbId: person.tmdbId),
            ),
            const SizedBox(height: 56),
          ]),
        ),
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
    final lifespan = _lifespan(person);

    // Full-bleed portrait as the hero backdrop, fading to black — same chrome
    // as the title hero.
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
                    if (lifespan != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          lifespan,
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

// ── Info ─────────────────────────────────────────────────────────────────

class _PersonInfoBlock extends StatelessWidget {
  const _PersonInfoBlock({required this.person});
  final Person person;

  /// The label/value pairs we actually have for this person.
  List<MapEntry<String, String>> get _rows {
    final rows = <MapEntry<String, String>>[];
    final prof = _departmentFull(person.knownForDepartment);
    if (prof != null) rows.add(MapEntry('Professione', prof));
    final birth = _fullDate(person.birthday);
    if (birth != null) rows.add(MapEntry('Data di nascita', birth));
    final place = person.placeOfBirth;
    if (place != null && place.isNotEmpty) {
      rows.add(MapEntry('Luogo di nascita', place));
    }
    final death = _fullDate(person.deathday);
    if (death != null) rows.add(MapEntry('Data di morte', death));
    final aka = _latinAka(person.alsoKnownAs);
    if (aka.isNotEmpty) {
      rows.add(MapEntry('Anche noto come', aka.join(' · ')));
    }
    return rows;
  }

  bool get hasContent => _rows.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    if (rows.isEmpty) return const SizedBox.shrink();
    final labelW = Responsive.isPhone(context) ? 120.0 : 150.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Info'),
        const SizedBox(height: 14),
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelW,
                  child: Text(
                    r.key,
                    style: StreamloadTypography.v3Body(
                      fontSize: 13,
                      color: StreamloadColors.v3TextMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    r.value,
                    style: StreamloadTypography.v3Body(
                      fontSize: 14,
                      color: StreamloadColors.v3TextPrimary,
                    ).copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Filmografia (paged) ────────────────────────────────────────────────────

class _FilmographySection extends ConsumerStatefulWidget {
  const _FilmographySection({required this.tmdbId});
  final int tmdbId;

  @override
  ConsumerState<_FilmographySection> createState() =>
      _FilmographySectionState();
}

class _FilmographySectionState extends ConsumerState<_FilmographySection> {
  bool _expanded = false;
  static const int _initial = 12;

  @override
  Widget build(BuildContext context) {
    final creditsAsync = ref.watch(personCreditsProvider(widget.tmdbId));
    return creditsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      ),
      error: (_, __) => const _FilmographyEmpty(),
      data: (items) {
        if (items.isEmpty) return const _FilmographyEmpty();
        // Backend already ranks by rating (70%) + popularity (30%), best first.
        final shown =
            _expanded ? items : items.take(_initial).toList(growable: false);
        final hasMore = items.length > shown.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Filmografia'),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 2 / 3,
              ),
              itemCount: shown.length,
              itemBuilder: (context, i) {
                final m = shown[i];
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
            ),
            if (hasMore || _expanded) ...[
              const SizedBox(height: 18),
              Center(
                child: _MoreButton(
                  expanded: _expanded,
                  remaining: items.length - shown.length,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.expanded,
    required this.remaining,
    required this.onTap,
  });
  final bool expanded;
  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = expanded ? 'Mostra meno' : 'Scopri di più ($remaining)';
    return PressFeedback(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: StreamloadColors.v3SurfaceGlass,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: StreamloadColors.v3BorderGlass),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: StreamloadTypography.v3Body(fontSize: 14).copyWith(
                  fontWeight: FontWeight.w600,
                  color: StreamloadColors.v3TextPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: StreamloadColors.v3TextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Identity helpers ───────────────────────────────────────────────────────

/// Eyebrow label (uppercase) for the hero.
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

/// Sentence-case profession for the Info block.
String? _departmentFull(String? dept) {
  if (dept == null || dept.isEmpty) return null;
  switch (dept) {
    case 'Acting':
      return 'Recitazione';
    case 'Directing':
      return 'Regia';
    case 'Writing':
      return 'Sceneggiatura';
    case 'Production':
      return 'Produzione';
    case 'Sound':
      return 'Sonoro';
    case 'Camera':
      return 'Fotografia';
    default:
      return dept;
  }
}

const _itMonths = [
  '', 'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
  'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
];

/// Full Italian date from a TMDB ISO string. Falls back to the bare year for
/// year-only / partial values; null when there's nothing parseable.
String? _fullDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
  if (m != null) {
    final year = int.parse(m.group(1)!);
    final month = int.parse(m.group(2)!);
    final day = int.parse(m.group(3)!);
    if (month >= 1 && month <= 12) return '$day ${_itMonths[month]} $year';
    return '$year';
  }
  return RegExp(r'^(\d{4})').firstMatch(iso)?.group(1);
}

/// "Also known as" is noisy — TMDB mixes in Greek/Cyrillic/Arabic/CJK
/// transliterations that mean nothing to an Italian user. Keep only the
/// Latin-script aliases (the real alternate names / stage names), drop
/// duplicates of the person's own name handling to the caller, cap at 3.
List<String> _latinAka(List<String> aka) {
  final latin = RegExp(r"^[\p{Script=Latin}0-9 .,'()&/-]+$", unicode: true);
  final out = <String>[];
  for (final a in aka) {
    final t = a.trim();
    if (t.isEmpty || !latin.hasMatch(t)) continue;
    out.add(t);
    if (out.length == 3) break;
  }
  return out;
}

String? _yearOf(String? iso) =>
    iso == null ? null : RegExp(r'^(\d{4})').firstMatch(iso)?.group(1);

/// Compact life-span line for the hero: "1963", or "1934 – 2023".
String? _lifespan(Person p) {
  final b = _yearOf(p.birthday);
  final d = _yearOf(p.deathday);
  if (d != null) return '${b ?? '?'} – $d';
  return b;
}

// ── States ───────────────────────────────────────────────────────────────

class _FilmographyEmpty extends StatelessWidget {
  const _FilmographyEmpty();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Filmografia'),
        const SizedBox(height: 16),
        Text(
          'Nessun titolo disponibile',
          style: StreamloadTypography.v3Body(
            fontSize: 14,
            color: StreamloadColors.v3TextMuted,
          ),
        ),
      ],
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
