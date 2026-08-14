import 'package:flutter/material.dart';

/// Generic chart header to apply to any chart to render header information
class SproutChartHeader extends StatelessWidget {
  final String? title;
  final String? subheader;

  /// Placed to the left of the center title
  final Widget? left;

  /// Placed to the right of the center title
  final Widget? right;

  const SproutChartHeader({
    super.key,
    this.title,
    this.subheader,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSideWidgets = left != null || right != null;

    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 4, right: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side slot
          if (hasSideWidgets)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: left ?? const SizedBox.shrink(),
              ),
            ),

          // Center title column
          Expanded(
            flex: hasSideWidgets ? 2 : 1,
            child: Column(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (title != null)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (subheader != null)
                  Text(
                    subheader!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
              ],
            ),
          ),

          // Right side slot
          if (hasSideWidgets)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: right ?? const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
