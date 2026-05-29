// lib/presentation/widgets/primitives/skeleton_box.dart
//
// A gently pulsing placeholder block. Used wherever real content is still
// loading so layouts reserve the correct space (no jump-on-load).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.65).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: StreamloadTokens.surfaceHi,
          borderRadius: widget.borderRadius ??
              BorderRadius.circular(StreamloadTokens.radiusCard),
        ),
      ),
    );
  }
}
