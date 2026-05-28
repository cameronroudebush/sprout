import 'package:flutter/material.dart';

/// Generic chart header to apply to any chart to render header information
class ChartHeader extends StatelessWidget {
  final String? title;
  final String? subheader;

  /// Placed to the left of the center title
  final Widget? left;
  // Placed to the right of the center title
  final Widget? right;

  const ChartHeader({super.key, this.title, this.subheader, this.left, this.right});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsetsGeometry.only(left: 12, top: 8, right: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: left ?? SizedBox.shrink()),
            Column(
              spacing: 4,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (title != null)
                  Text(title!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (subheader != null)
                  Text(subheader!, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
              ],
            ),
            Expanded(child: right ?? SizedBox.shrink()),
          ],
        ));
  }
}
