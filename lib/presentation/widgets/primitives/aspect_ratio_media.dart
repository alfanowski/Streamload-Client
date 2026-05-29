// lib/presentation/widgets/primitives/aspect_ratio_media.dart
//
// Aspect-locked media tile. Guarantees: never overflows (AspectRatio +
// ClipRRect), always shows *something* (skeleton while loading, initials
// fallback on null/empty/error). This is the only way the app loads poster /
// backdrop imagery — no raw Image.network anywhere.
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import 'skeleton_box.dart';

class AspectRatioMedia extends StatelessWidget {
  const AspectRatioMedia({
    super.key,
    required this.aspectRatio,
    required this.imageUrl,
    required this.fallbackLabel,
    this.borderRadius,
  });

  final double aspectRatio;
  final String? imageUrl;
  final String fallbackLabel;
  final BorderRadius? borderRadius;

  bool get _hasUrl => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(StreamloadTokens.radiusCard);
    return ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: _hasUrl
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SkeletonBox(),
                errorWidget: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: StreamloadTokens.surfaceHi,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(StreamloadTokens.space2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          _initials(fallbackLabel),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StreamloadTokens.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _initials(String raw) {
    final parts =
        raw.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
