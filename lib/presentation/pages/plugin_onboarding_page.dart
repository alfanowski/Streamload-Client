// lib/presentation/pages/plugin_onboarding_page.dart
//
// Cinematic, minimal GitHub device-flow login. A slowly-drifting, shuffled wall
// of PRESTIGE posters (bundled assets, always present even pre-auth/offline)
// sits behind a bottom-anchored block: a big Fraunces "Streamload" wordmark, a
// quality slogan, and a minimal auth card (idle → a single GitHub button;
// awaiting → code + back). All OAuth + auth-handoff logic is preserved; the
// login→home transition is a single crossfade driven by the router.
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../plugins/github_oauth.dart';
import '../../plugins/github_oauth_config.dart';
import '../../state/auth_provider.dart';
import '../../state/github_token_provider.dart';
import '../../state/plugins_provider.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';
import '../widgets/auth/login_posters.dart';

typedef OAuthFactory = GithubOAuth Function();

GithubOAuth _defaultFactory() => GithubOAuth(clientId: kGithubOAuthClientId);

enum _OnboardingState { idle, awaitingUser, error }

class PluginOnboardingPage extends ConsumerStatefulWidget {
  const PluginOnboardingPage({super.key, this.oauthFactory = _defaultFactory});
  final OAuthFactory oauthFactory;

  @override
  ConsumerState<PluginOnboardingPage> createState() =>
      _PluginOnboardingPageState();
}

class _PluginOnboardingPageState extends ConsumerState<PluginOnboardingPage>
    with SingleTickerProviderStateMixin {
  _OnboardingState _state = _OnboardingState.idle;
  DeviceCodeRequest? _device;
  String? _error;
  bool _starting = false;

  // Bumped every time a flow starts or is cancelled — lets an in-flight poll
  // know it's stale (so "back" truly aborts and never navigates late).
  int _attempt = 0;

  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final attempt = ++_attempt;
    setState(() {
      _state = _OnboardingState.awaitingUser;
      _starting = true;
      _error = null;
      _device = null;
    });
    final oauth = widget.oauthFactory();
    try {
      final dev = await oauth.requestDeviceCode();
      if (!mounted || attempt != _attempt) return;
      setState(() {
        _device = dev;
        _starting = false;
      });
      // Open the verification page in the browser to nudge the user.
      try {
        await launchUrl(
          Uri.parse(dev.verificationUri),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        // Proceed even if the browser launch fails (e.g., in tests).
      }
      final token = await oauth.pollForToken(
        deviceCode: dev.deviceCode,
        interval: dev.pollInterval,
        timeout: dev.expiresIn,
      );
      if (!mounted || attempt != _attempt) return;
      await ref.read(githubTokenProvider.notifier).save(token);
      final user = await ref.read(authProvider.notifier).loginWithGithub(token);
      if (!mounted || attempt != _attempt) return;
      // ignore: unawaited_futures
      unawaited(ref.read(pluginRefreshControllerProvider.notifier).refresh());
      // The login→home transition is a single crossfade: the onboarding route
      // fades out (via its secondaryAnimation) while /home fades in — see
      // router. One continuous motion, no bespoke exit animation here.
      context.go(user.profileComplete ? '/home' : '/onboarding/profile');
    } on DeviceFlowDenied {
      if (mounted && attempt == _attempt) {
        _setError("Accesso annullato. Riprova quando vuoi.");
      }
    } on DeviceFlowExpired {
      if (mounted && attempt == _attempt) {
        _setError('Il codice è scaduto. Riprova.');
      }
    } catch (e) {
      if (mounted && attempt == _attempt) {
        _setError('Qualcosa è andato storto.');
      }
    }
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _state = _OnboardingState.error;
      _starting = false;
      _error = msg;
    });
  }

  /// Abort whatever is in flight and return to the start. Bumping [_attempt]
  /// makes any still-running poll discard its result.
  void _cancel() {
    setState(() {
      _attempt++;
      _state = _OnboardingState.idle;
      _starting = false;
      _error = null;
      _device = null;
    });
  }

  Future<void> _copyCode() async {
    if (_device == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: _device!.userCode));
    } catch (_) {}
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Codice copiato')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordmarkAnim = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    );
    final cardAnim = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic),
    );

    return Scaffold(
      backgroundColor: StreamloadColors.v3BgBase,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Living, prestige poster wall ──
          const _PosterWall(posters: kLoginPosters),
          // ── Scrim: light in the middle (posters show), heavy at bottom ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x22000000),
                  Color(0xCC0B0B0C),
                  Color(0xFF000000),
                ],
                stops: [0.06, 0.34, 0.66, 1.0],
              ),
            ),
          ),
          // ── Top fade into black behind the Dynamic Island / status bar,
          //    same as the Home screen so the clock stays legible. ──
          const Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCC000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
          // ── Bottom-anchored content ──
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Rise(animation: wordmarkAnim, child: const _Wordmark()),
                      const SizedBox(height: 26),
                      _Rise(
                        animation: cardAnim,
                        child: _LoginCard(
                          // AnimatedSize tweens the card height; the switcher
                          // crossfades the content in place → nothing snaps.
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  ...previous,
                                  if (current != null) current,
                                ],
                              ),
                              child: switch (_state) {
                                _OnboardingState.idle => _IdleView(
                                    key: const ValueKey('idle'),
                                    busy: _starting,
                                    onStart: _start,
                                  ),
                                _OnboardingState.awaitingUser => _AwaitingView(
                                    key: const ValueKey('await'),
                                    device: _device,
                                    onCopy: _copyCode,
                                    onCancel: _cancel,
                                  ),
                                _OnboardingState.error => _ErrorView(
                                    key: const ValueKey('error'),
                                    message: _error ?? '',
                                    onRetry: _start,
                                    onCancel: _cancel,
                                  ),
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'by alfanowski',
                        textAlign: TextAlign.center,
                        style: StreamloadTypography.v3LabelMono(
                          color: StreamloadColors.v3TextMuted,
                        ).copyWith(
                          letterSpacing: 1.2,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fade + rise entrance.
class _Rise extends StatelessWidget {
  const _Rise({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 22 * (1 - animation.value)),
          child: child,
        ),
        child: child,
      ),
    );
  }
}

/// Editorial wordmark + a one-line quality slogan.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Streamload',
          style: StreamloadTypography.v3DisplayHero().copyWith(
            fontSize: 52,
            color: StreamloadColors.v3TextPrimary,
            height: 1.0,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 28)],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tutto il cinema a portata di mano',
          style: StreamloadTypography.v3DisplayPage().copyWith(
            fontSize: 17,
            color: StreamloadColors.v3TextSecondary,
            shadows: const [Shadow(color: Colors.black87, blurRadius: 16)],
          ),
        ),
      ],
    );
  }
}

/// Translucent dark card — NO BackdropFilter (ugly opaque rect on the iOS
/// simulator); a flat dark fill over the posters reads as clean glass.
class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(StreamloadSpacing.cardRadiusLarge),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Auth states
// ──────────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({super.key, required this.busy, required this.onStart});
  final bool busy;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return _GithubButton(
      key: const Key('onboarding.github_login'),
      busy: busy,
      onPressed: busy ? null : onStart,
    );
  }
}

class _AwaitingView extends StatelessWidget {
  const _AwaitingView({
    super.key,
    required this.device,
    required this.onCopy,
    required this.onCancel,
  });

  final DeviceCodeRequest? device;
  final VoidCallback onCopy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (device == null) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CardHeader(title: 'Inserisci il codice', onBack: onCancel),
        const SizedBox(height: 16),
        // Code chip (tap to copy)
        GestureDetector(
          onTap: onCopy,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    device!.userCode,
                    key: const Key('onboarding.user_code'),
                    style: StreamloadTypography.v3MetaMono(
                      color: StreamloadColors.v3TextPrimary,
                    ).copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.55),
                    key: const Key('onboarding.copy_code'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 13,
              height: 13,
              child: CircularProgressIndicator(
                  strokeWidth: 1.6, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'In attesa di conferma su GitHub…',
              style: StreamloadTypography.v3MetaMono(
                color: StreamloadColors.v3TextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CardHeader(title: 'Riprova', onBack: onCancel),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: StreamloadTypography.v3Body(
            fontSize: 14,
            color: StreamloadColors.v3TextSecondary,
          ),
        ),
        const SizedBox(height: 18),
        _GithubButton(
          key: const Key('onboarding.retry'),
          busy: false,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

/// Small header row: a back chevron + a quiet title. Lets the user step back
/// out of any in-flight state.
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBack,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: StreamloadTypography.v3DisplayPage().copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

/// The one and only auth control — the classic black-on-white GitHub button.
class _GithubButton extends StatelessWidget {
  const _GithubButton({super.key, required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: busy
                ? const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    ),
                  ]
                : const [
                    FaIcon(FontAwesomeIcons.github,
                        color: Colors.black, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Continua con GitHub',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Drifting poster wall
// ──────────────────────────────────────────────────────────────────────────

/// Full-bleed wall of prestige posters: shuffled at launch, tilted columns that
/// drift slowly + endlessly at different periods/directions/phases (parallax).
/// Decorative only.
class _PosterWall extends StatefulWidget {
  const _PosterWall({required this.posters});
  final List<String> posters;

  @override
  State<_PosterWall> createState() => _PosterWallState();
}

class _PosterWallState extends State<_PosterWall> {
  static const int _cols = 5;
  // Per-column loop period (seconds). Different periods → parallax. Each column
  // owns its controller, so there's no shared wrap → endless, no jump back.
  static const _periods = [150, 200, 130, 185, 165];

  // DISJOINT partition of the shuffled posters, one list per column. No poster
  // appears in two columns → the same cover can never show up twice on screen
  // at once.
  late final List<List<String>> _columns;
  late final List<double> _phases;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final shuffled = [...widget.posters]..shuffle(rng);
    _columns = List.generate(_cols, (_) => <String>[]);
    for (var i = 0; i < shuffled.length; i++) {
      _columns[i % _cols].add(shuffled[i]);
    }
    // Random start phase per column → never aligned, no empty band at t=0,
    // and a different look on every launch.
    _phases = List.generate(_cols, (_) => rng.nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Transform.rotate(
            angle: -0.12,
            child: Transform.scale(
              scale: 1.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _cols; i++) ...[
                    if (i > 0) const SizedBox(width: 9),
                    _PosterColumn(
                      posters: _columns[i],
                      periodSeconds: _periods[i],
                      up: i.isEven,
                      phase: _phases[i],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterColumn extends StatefulWidget {
  const _PosterColumn({
    required this.posters,
    required this.periodSeconds,
    required this.up,
    required this.phase,
  });

  final List<String> posters;
  final int periodSeconds;
  final bool up;
  final double phase;

  @override
  State<_PosterColumn> createState() => _PosterColumnState();
}

class _PosterColumnState extends State<_PosterColumn>
    with SingleTickerProviderStateMixin {
  static const double _tileW = 108;
  static const double _tileH = 162; // 2:3
  static const double _gap = 9;

  late final AnimationController _ctrl;
  late final Widget _column;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.periodSeconds),
    )..repeat();
    // Built once — only the transform moves, the images don't rebuild.
    _column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final _ in [0, 1])
          for (final asset in widget.posters)
            Padding(
              padding: const EdgeInsets.only(bottom: _gap),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  asset,
                  width: _tileW,
                  height: _tileH,
                  fit: BoxFit.cover,
                  cacheWidth: 220,
                  gaplessPlayback: true,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: _tileW,
                    height: _tileH,
                    child: ColoredBox(color: Color(0x1FFFFFFF)),
                  ),
                ),
              ),
            ),
      ],
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setHeight = widget.posters.length * (_tileH + _gap);
    return SizedBox(
      width: _tileW,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          // (value + phase) % 1 is continuous across the controller's 1→0 wrap
          // (both ends == phase), and the doubled content makes the internal
          // wrap seamless too → no visible jump, ever.
          final v = (_ctrl.value + widget.phase) % 1.0;
          final dy = widget.up ? -v * setHeight : (v - 1) * setHeight;
          return Transform.translate(offset: Offset(0, dy), child: child);
        },
        child: _column,
      ),
    );
  }
}
