import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The original dark theme of Sprout that utilizes it's primary colors as necessary
final ThemeData coloredDarkTheme = FlexThemeData.dark(
  fontFamily: 'RobotoCrisp',
  colors: const FlexSchemeColor(
    primary: Color(0xff6b9ac4),
    primaryContainer: Color(0xff001e2c),
    secondary: Color(0xff116383),
    secondaryContainer: Color(0xffc2e8ff),
    tertiary: Color(0xffd6bee4),
    tertiaryContainer: Color(0xff523f5f),
    error: Color(0xffba1a1a),
  ),
  scaffoldBackground: const Color(0xff111418),
  subThemesData: const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    segmentedButtonSchemeColor: SchemeColor.primary,
    segmentedButtonSelectedForegroundSchemeColor: SchemeColor.onPrimary,
    segmentedButtonUnselectedForegroundSchemeColor: SchemeColor.onSurface,
    segmentedButtonBorderSchemeColor: SchemeColor.outlineVariant,
    fabSchemeColor: SchemeColor.secondary,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  platform: TargetPlatform.windows,
  cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
).copyWith(
  popupMenuTheme: const PopupMenuThemeData(
    color: Color(0xff191c20),
    surfaceTintColor: Colors.transparent,
  ),
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xff191c20)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xff191c20)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dividerTheme: DividerThemeData(color: Color(0xff116383).withOpacity(.35)),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xff191c20),
    disabledColor: const Color(0xff191c20).withOpacity(0.4),
    labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
  ),
  cardTheme: const CardThemeData(color: Color(0xff191c20)),
  dialogTheme: DialogThemeData(backgroundColor: Color(0xff14171b)),
  listTileTheme: ListTileThemeData(),
  drawerTheme: DrawerThemeData(),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xff6b9ac4),
    refreshBackgroundColor: Color(0xff6b9ac4),
  ),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xff191c20)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xff191c20),
    unselectedItemColor: Colors.white,
  ),
  canvasColor: const Color(0xff191c20),
  dividerColor: Color(0xff116383),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(color: const Color(0xff116383), borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    waitDuration: const Duration(milliseconds: 500),
    showDuration: const Duration(seconds: 2),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    side: const BorderSide(color: Colors.white, width: 1),
  )),
);
