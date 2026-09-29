import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// Defines one labeled option for [SproutTabSelector].
class SproutTabOption<T extends Object> {
  final T value;
  final String label;

  const SproutTabOption({required this.value, required this.label});
}

/// Displays scrollable underlined tabs or compact segmented controls for mobile.
class SproutTabSelector<T extends Object> extends StatelessWidget {
  /// Options available to the user, in display order.
  final List<SproutTabOption<T>> options;

  /// Value whose label and underline are currently selected.
  final T selected;

  /// Called when the user selects an option.
  final ValueChanged<T> onSelected;

  /// Whether tabs should use all finite available width when options fit.
  final bool expand;

  /// Uses a compact Material segmented control instead of underlined tabs.
  final bool compact;

  const SproutTabSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.expand = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (compact) {
      return SegmentedButton<T>(
        showSelectedIcon: false,
        segments: options
            .map((option) => ButtonSegment<T>(
                  value: option.value,
                  label: Text(option.label, maxLines: 1, softWrap: false),
                ))
            .toList(),
        selected: {selected},
        onSelectionChanged: (selection) {
          if (selection.isNotEmpty) onSelected(selection.first);
        },
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: expand && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 0,
            children: options.map((option) {
              final isSelected = option.value == selected;
              final foreground =
                  isSelected ? colors.primary : colors.onSurfaceVariant;
              final labelStyle = theme.textTheme.titleMedium?.copyWith(
                color: foreground,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              );
              final labelPainter = TextPainter(
                text: TextSpan(text: option.label, style: labelStyle),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
              )..layout();
              final tabWidth = labelPainter.width;

              return Semantics(
                button: true,
                selected: isSelected,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelected(option.value),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                option.label,
                                style: labelStyle,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              height: 3,
                              width: tabWidth,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Reserves content space for mobile navigation and hides it on desktop.
class SproutTabbedLayout extends StatelessWidget {
  final Widget child;
  final Widget mobileNavigation;
  final EdgeInsetsGeometry mobileNavigationPadding;

  const SproutTabbedLayout({
    super.key,
    required this.child,
    required this.mobileNavigation,
    this.mobileNavigationPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder(
      (isDesktop, context, constraints) => Column(
        children: [
          Expanded(child: child),
          if (!isDesktop)
            SafeArea(
              top: false,
              child: Padding(
                padding: mobileNavigationPadding,
                child: mobileNavigation,
              ),
            ),
        ],
      ),
    );
  }
}
