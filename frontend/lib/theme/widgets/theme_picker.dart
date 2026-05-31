import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/widgets/tiles/setting_tile.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';
import 'package:sprout/theme/absolute_dark.dart';
import 'package:sprout/theme/bliss_light.dart';
import 'package:sprout/theme/colored_dark.dart';

/// An inline theme choice selector
class ThemePicker extends StatelessWidget {
  final ThemeStyleEnum currentStyle;
  final ValueChanged<ThemeStyleEnum> onThemeChanged;

  const ThemePicker({
    super.key,
    required this.currentStyle,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: "App Theme",
      subtitle: "Select a workspace profile environment that fits your eye",
      icon: Icons.palette_outlined,
      child: Row(
        spacing: 12,
        children: ThemeStyleEnum.values.map((style) {
          final isSelected = currentStyle == style;

          final targetTheme = switch (style) {
            ThemeStyleEnum.bliss => blissLightTheme,
            ThemeStyleEnum.colored => coloredDarkTheme,
            ThemeStyleEnum.absolute => absoluteDarkTheme,
            _ => absoluteDarkTheme,
          };

          final scaffoldColor = targetTheme.scaffoldBackgroundColor;
          final sidebarColor = targetTheme.cardTheme.color ?? targetTheme.cardColor;
          final surfaceCardColor = targetTheme.cardTheme.color ?? targetTheme.cardColor;
          final accentColor = targetTheme.colorScheme.primary;
          final isLight = targetTheme.brightness == Brightness.light;

          return Expanded(
            child: InkWell(
              onTap: () => onThemeChanged(style),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withOpacity(0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            color: scaffoldColor,
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  decoration: BoxDecoration(
                                    color: sidebarColor,
                                    border: style == ThemeStyleEnum.absolute
                                        ? const Border(right: BorderSide(color: Color(0xFF1F1F1F), width: 0.5))
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: Column(
                                    spacing: 4,
                                    children: List.generate(
                                      4,
                                      (index) => Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: index == 0
                                              ? accentColor
                                              : (isLight ? Colors.grey.shade300 : Colors.grey.shade700),
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      spacing: 6,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: 4,
                                              width: 25,
                                              decoration: BoxDecoration(
                                                color: isLight ? Colors.grey.shade400 : Colors.grey.shade600,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                            CircleAvatar(radius: 2.5, backgroundColor: accentColor),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: surfaceCardColor,
                                            borderRadius: BorderRadius.circular(4),
                                            border: style == ThemeStyleEnum.absolute
                                                ? Border.all(color: const Color(0xFF1F1F1F), width: 0.5)
                                                : Border.all(
                                                    color: isLight ? Colors.grey.shade200 : Colors.grey.shade800,
                                                    width: 0.5,
                                                  ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            spacing: 3,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                spacing: 2,
                                                children: [
                                                  Container(height: 5, width: 3, color: accentColor.withOpacity(0.3)),
                                                  Container(height: 9, width: 3, color: accentColor.withOpacity(0.5)),
                                                  Container(height: 12, width: 3, color: accentColor),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: sidebarColor.withOpacity(0.85),
                              border: Border(
                                top: BorderSide(
                                  color: isLight ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.05),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              style.value.toTitleCase,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isLight ? Colors.black : Colors.white,
                              ),
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
    );
  }
}
