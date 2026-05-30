// lib/presentation/widgets/mobile_top_bar.dart
//
// Phone-only floating top bar: the Streamload wordmark + a cast button.
// It's a liquid-glass surface that FLOATS over the page — content scrolls
// under it and blurs through (native Apple glass on iOS, shader/blur
// elsewhere), matching the bottom tab bar.
//
// Cast icon: AirPlay on iOS, the classic cast glyph on Android. UI-only for
// now (real AirPlay / Chromecast wiring is a dedicated follow-up); tapping
// shows a "coming soon" hint so it never feels dead.
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'primitives/glass_surface.dart';

class StreamloadMobileTopBar extends StatelessWidget {
  const StreamloadMobileTopBar({super.key});

  /// Bar height below the status-bar inset.
  static const double height = 52;

  static IconData get _castIcon {
    if (kIsWeb) return Icons.cast;
    try {
      return Platform.isIOS ? Icons.airplay : Icons.cast;
    } catch (_) {
      return Icons.cast;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      borderRadius: 0,
      blur: 14,
      thickness: 8,
      tint: StreamloadTokens.bg.withValues(alpha: 0.28),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Streamload',
                  style:
                      StreamloadTypography.display(fontSize: 19, italic: true)
                          .copyWith(
                    letterSpacing: -0.3,
                    color: StreamloadTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                _CastButton(icon: _castIcon),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CastButton extends StatelessWidget {
  const _CastButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cast — in arrivo'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: StreamloadTokens.textPrimary),
      ),
    );
  }
}
