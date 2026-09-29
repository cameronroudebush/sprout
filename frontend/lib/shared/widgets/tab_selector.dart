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

  /// Expands compact segments to fill their available width.
  final bool fill;

  const SproutTabSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.expand = true,
    this.compact = false,
    this.fill = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (compact) {
      return SegmentedButton<T>(
        showSelectedIcon: false,
        expandedInsets: fill ? EdgeInsets.zero : null,
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
          side: BorderSide.none,
          shape: fill
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                )
              : null,
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

/// Overlays mobile navigation on page content and hides it on desktop.
///
/// Mobile navigation is selected automatically: up to two tabs use segmented
/// buttons, while larger tab sets use a dropdown.
class SproutTabbedLayout<T extends Object> extends StatelessWidget {
  /// Extra scroll extent needed to bring content above the mobile tab overlay.
  static const double mobileNavigationScrollInset = 64;

  final Widget child;
  final List<SproutTabOption<T>> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry mobileNavigationPadding;
  final String dropdownTooltip;
  final String dropdownHeading;
  final IconData dropdownIcon;

  const SproutTabbedLayout({
    super.key,
    required this.child,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    this.dropdownTooltip = 'Select tab',
    this.dropdownHeading = 'TABS',
    this.dropdownIcon = Icons.list_rounded,
    this.mobileNavigationPadding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  }) : assert(tabs.length > 0);

  Widget _buildMobileNavigation(BuildContext context) {
    final activeTab =
        tabs.any((tab) => tab.value == selected) ? selected : tabs.first.value;
    final theme = Theme.of(context);

    final Widget navigation;
    if (tabs.length <= 2) {
      navigation = SproutTabSelector<T>(
        options: tabs,
        selected: activeTab,
        onSelected: onSelected,
        compact: true,
        fill: true,
      );
    } else {
      final selectedTab = tabs.firstWhere(
        (tab) => tab.value == activeTab,
        orElse: () => tabs.first,
      );

      navigation = LayoutBuilder(
        builder: (context, constraints) => PopupMenuButton<T>(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          tooltip: dropdownTooltip,
          position: PopupMenuPosition.over,
          onSelected: onSelected,
          itemBuilder: (context) => tabs
              .map(
                (tab) => PopupMenuItem<T>(
                  value: tab.value,
                  child: Row(
                    spacing: 12,
                    children: [
                      Icon(
                        tab.value == activeTab
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 18,
                        color: tab.value == activeTab
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      Text(tab.label),
                    ],
                  ),
                ),
              )
              .toList(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              // color: theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    dropdownIcon,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dropdownHeading,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        selectedTab.label,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.expand_less_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * .7,
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor ??
              theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: navigation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder(
      (isDesktop, context, constraints) => Stack(
        children: [
          Positioned.fill(child: child),
          if (!isDesktop)
            Positioned(
              left: 0,
              right: 0,
              bottom: -6,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: mobileNavigationPadding,
                  child: _buildMobileNavigation(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
