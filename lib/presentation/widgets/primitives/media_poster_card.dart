// lib/presentation/widgets/primitives/media_poster_card.dart
//
// The single poster tile used by rows and grids. Composes AspectRatioMedia
// (overflow-safe, fallback) with a title + meta line from MediaCardVm. The
// optional amber progress bar marks "continue watching". Text uses plain
// TextStyle so it inherits the ambient theme font (and stays test-safe).
//
// Parity with the legacy PosterCard: PressFeedback squeeze on tap + a
// subtle 1.0→1.04 hover scale on desktop/tablet (phones skip it — they
// never fire MouseRegion hover). `width` is optional: pass a fixed width
// inside a row, or leave it null to fill a grid cell.
import 'package:flutter/material.dart';

import '../../responsive.dart';
import '../../theme/tokens.dart';
import '../../view_models/media_card_vm.dart';
import '../press_feedback.dart';
import 'aspect_ratio_media.dart';

class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({
    super.key,
    required this.item,
    this.width,
    this.progress,
    this.onTap,
  });

  final MediaCardVm item;

  /// Fixed card width (used inside horizontal rows). Null → fills the
  /// parent's width (used inside a grid cell).
  final double? width;

  /// 0..1 resume progress. Null or <= 0 hides the bar.
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hoverable = !Responsive.isMobile(context);
    final card = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _content(),
    );
    final scaled = _HoverScale(enabled: hoverable, child: card);
    final sized =
        width == null ? scaled : SizedBox(width: width, child: scaled);
    return PressFeedback(child: sized);
  }

  Widget _content() {
    final showProgress = progress != null && progress! > 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatioMedia(
              aspectRatio: 2 / 3,
              imageUrl: item.posterUrl,
              fallbackLabel: item.title,
            ),
            if (showProgress)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _ProgressBar(
                  key: const Key('poster-progress'),
                  value: progress!.clamp(0.0, 1.0),
                ),
              ),
          ],
        ),
        const SizedBox(height: StreamloadTokens.space2),
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: StreamloadTokens.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (item.metaLine.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              item.metaLine,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: StreamloadTokens.textMuted,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(StreamloadTokens.radiusCard),
      ),
      child: Container(
        height: 4,
        color: StreamloadTokens.surfaceHi,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value,
          child: const ColoredBox(color: Colors.white),
        ),
      ),
    );
  }
}

/// Subtle editorial hover — 1.0→1.04 scale. Desktop/tablet only; phones
/// skip it (MouseRegion never fires hover for them).
class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child, required this.enabled});
  final Widget child;
  final bool enabled;

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.04 : 1.0,
        duration: StreamloadTokens.hover,
        curve: StreamloadTokens.standardCurve,
        child: widget.child,
      ),
    );
  }
}
