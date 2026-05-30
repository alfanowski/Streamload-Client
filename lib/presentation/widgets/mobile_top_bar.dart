// lib/presentation/widgets/mobile_top_bar.dart
//
// Phone-only top bar: the Streamload wordmark on the left + a cast button on
// the right (Netflix / Disney+ mobile pattern). Fixed header with its own
// space — content lives below it. The cast button is UI-only for now (real
// AirPlay / Chromecast wiring is a dedicated follow-up); tapping it shows a
// "coming soon" hint so it never feels dead.
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

class StreamloadMobileTopBar extends StatelessWidget {
  const StreamloadMobileTopBar({super.key});

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Streamload',
                style: StreamloadTypography.display(fontSize: 19, italic: true)
                    .copyWith(
                  letterSpacing: -0.3,
                  color: StreamloadTokens.textPrimary,
                ),
              ),
              const Spacer(),
              _CastButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CastButton extends StatelessWidget {
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
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Icon(
          Icons.cast,
          size: 22,
          color: StreamloadTokens.textPrimary,
        ),
      ),
    );
  }
}
