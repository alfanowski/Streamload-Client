// lib/presentation/pages/person_page.dart
//
// Pass 3 CAST-5 — editorial actor / director page. Magazine hero (rounded
// portrait + Fraunces italic name + monospace birth line + Italian
// eyebrow label) over a centered biography and the popularity-sorted
// PosterRow of every title in the person's filmography.
//
// State:
//   - personProvider(tmdbId) → Person bio
//   - personCreditsProvider(tmdbId) → List<MediaSummary> filmography
// Both autoDispose so navigating between actors doesn't keep stale
// futures in memory. Tap any title card → /title/<id>?media_type=<mt>
// (default PosterRow handler).
//
// Editorial discipline notes:
//   - portrait is a magazine-square (aspect 3:4), NOT circular — round
//     avatars are for the small CastCard chips, not the page hero
//   - typography uses display(italic) for the name, v3MetaMono for the
//     birth line, v3LabelMono for the eyebrow, v3Body 16 for the bio
//   - biography is constrained to maxWidth 720 like the title page
//     synopsis so the line length stays magazine-readable
//   - no animations beyond the global page fade route — no Ken Burns,
//     no parallax, no spring physics
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/person.dart';
import '../../state/person_provider.dart';
import '../responsive.dart';
import '../widgets/top_nav_bar.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/rows/poster_row.dart';

class PersonPage extends ConsumerWidget {
  const PersonPage({super.key, required this.tmdbId});

  final int tmdbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personProvider(tmdbId));
    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      body: personAsync.when(
        loading: () => const _Skeleton(),
        error: (e, _) => _ErrorState(
          message: '$e',
          onRetry: () => ref.invalidate(personProvider(tmdbId)),
        ),
        data: (person) => _PersonBody(person: person),
      ),
    );
  }
}

class _PersonBody extends ConsumerWidget {
  const _PersonBody({required this.person});
  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsAsync = ref.watch(personCreditsProvider(person.tmdbId));
    // Phone: just clear the status bar / Dynamic Island. Desktop: clear the
    // floating top nav bar.
    final topInset = Responsive.isPhone(context)
        ? MediaQuery.of(context).padding.top + 8
        : TopNavBar.height + MediaQuery.of(context).padding.top;
    return ListView(
      padding: EdgeInsets.only(top: topInset),
      children: [
        _Hero(person: person),
        if ((person.biography ?? '').isNotEmpty) ...[
          const SizedBox(height: 40),
          _Biography(body: person.biography!),
        ],
        const SizedBox(height: 40),
        creditsAsync.when(
          loading: () => const PosterRow(
            title: 'Filmografia',
            items: [],
            isLoading: true,
          ),
          error: (_, __) => const _FilmographyEmpty(),
          data: (items) => items.isEmpty
              ? const _FilmographyEmpty()
              : PosterRow(title: 'Filmografia', items: items),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.person});
  final Person person;

  // Portrait sizing for desktop / tablet. Phone uses a centered constrained
  // copy. Capped at 380 px wide to keep the hero from swallowing wide
  // viewports.
  static const double _portraitMaxWidth = 380;
  static const double _portraitTabletWidth = 280;
  static const double _portraitPhoneWidth = 240;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final pagePad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : isTablet
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;
    final nameSize = isPhone ? 36.0 : (isTablet ? 48.0 : 64.0);

    final portrait = _Portrait(profileUrl: person.profileUrl);
    final stack = _IdentityStack(person: person, nameSize: nameSize);

    if (isPhone) {
      // Stacked layout — portrait centered above the identity stack.
      // Height collapses to content (no fixed SizedBox) so the ListView
      // never overflows on short viewports.
      return Padding(
        padding: pagePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: _portraitPhoneWidth,
                child: portrait,
              ),
            ),
            const SizedBox(height: 24),
            stack,
          ],
        ),
      );
    }

    return Padding(
      padding: pagePad,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: isTablet
                  ? _portraitTabletWidth
                  : _portraitMaxWidth,
              child: portrait,
            ),
            const SizedBox(width: 40),
            Expanded(child: stack),
          ],
        ),
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({required this.profileUrl});
  final String? profileUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
          border: Border.all(
            color: StreamloadColors.v3BorderGlass,
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
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
          size: 56,
        ),
      ),
    );
  }
}

class _IdentityStack extends StatelessWidget {
  const _IdentityStack({required this.person, required this.nameSize});
  final Person person;
  final double nameSize;

  @override
  Widget build(BuildContext context) {
    final eyebrow = _italianDepartment(person.knownForDepartment);
    final birthLine = _formatBirthLine(person);
    final aka = person.alsoKnownAs.isNotEmpty
        ? person.alsoKnownAs.join(', ')
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (eyebrow != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(eyebrow, style: StreamloadTypography.v3LabelMono()),
          ),
        Text(
          person.name,
          style: StreamloadTypography.display(
            fontSize: nameSize,
            italic: true,
          ),
        ),
        if (birthLine != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              birthLine,
              style: StreamloadTypography.v3MetaMono(
                fontSize: 13,
              ),
            ),
          ),
        if (aka != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              aka,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: StreamloadTypography.v3MetaMono(
                fontSize: 11,
                color: StreamloadColors.v3TextMuted,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pass 3 visual decision: we keep the eyebrow English-mapping local to
/// the page since this is the only consumer. If a future Person UI needs
/// the same mapping it'll be cheap to lift this into a utility.
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

/// Returns null when there's no birthday to render. Handles the three
/// shapes TMDB sends: full ISO, year-only, and (rarely) day-only — we
/// fall back to "n. YYYY" for anything we can parse.
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
      // Year-only or unparseable — surface as "n. <birth>" so the page
      // doesn't render a half-broken date.
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

class _Biography extends StatelessWidget {
  const _Biography({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    final isPhone = Responsive.isPhone(context);
    final isTablet = Responsive.isTablet(context);
    final pagePad = isPhone
        ? StreamloadSpacing.pagePaddingPhone
        : isTablet
            ? StreamloadSpacing.pagePaddingTablet
            : StreamloadSpacing.pagePaddingDesktop;
    return Padding(
      padding: pagePad,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            body,
            style: StreamloadTypography.v3Body(fontSize: 16).copyWith(
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilmographyEmpty extends StatelessWidget {
  const _FilmographyEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
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
    // Skeleton uses a ListView so it doesn't fight the bounded viewport
    // during the brief loading frame that precedes data resolution in
    // both real use and widget tests.
    return ListView(
      key: const Key('person-page-skeleton'),
      padding: const EdgeInsets.all(32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 280,
              height: 380,
              decoration: BoxDecoration(
                color: StreamloadColors.v3SurfaceGlass,
                borderRadius:
                    BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
              ),
            ),
            const SizedBox(width: 40),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkelBar(widthFactor: 0.4, height: 14),
                  SizedBox(height: 24),
                  _SkelBar(widthFactor: 0.7, height: 48),
                  SizedBox(height: 24),
                  _SkelBar(widthFactor: 0.55, height: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        const _SkelBar(widthFactor: 1.0, height: 200),
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
