// lib/presentation/widgets/primitives/responsive_grid.dart
//
// Aligned, breakpoint-aware grid. Column count derives from the available
// width via StreamloadTokens breakpoints, so the last row is never lopsided
// and tiles never overflow. Non-scrolling by default (meant to live inside
// a CustomScrollView/Column on a page that scrolls as a whole).
import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.itemAspectRatio,
    this.spacing = StreamloadTokens.space3,
    this.phoneColumns = 3,
    this.tabletColumns = 4,
    this.desktopColumns = 6,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double itemAspectRatio;
  final double spacing;
  final int phoneColumns;
  final int tabletColumns;
  final int desktopColumns;

  static int columnsForWidth(
    double width, {
    required int phoneColumns,
    required int tabletColumns,
    required int desktopColumns,
  }) {
    if (width < StreamloadTokens.bpPhone) return phoneColumns;
    if (width < StreamloadTokens.bpDesktop) return tabletColumns;
    return desktopColumns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsForWidth(
          constraints.maxWidth,
          phoneColumns: phoneColumns,
          tabletColumns: tabletColumns,
          desktopColumns: desktopColumns,
        );
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: itemAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
