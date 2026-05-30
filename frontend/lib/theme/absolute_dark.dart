import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprout/theme/helpers.dart';

/// Absolute dark defines a super dark theme
final ThemeData absoluteDarkTheme = FlexThemeData.dark(
  colors: const FlexSchemeColor(
    primary: ThemeHelpers.primaryBlue,
    primaryContainer: Color(0xff001e2c),
    secondary: Color(0xff116383),
    secondaryContainer: Color(0xffc2e8ff),
    tertiary: Color(0xffd6bee4),
    tertiaryContainer: Color(0xff523f5f),
    error: Color(0xffba1a1a),
  ),
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  darkIsTrueBlack: true,
  subThemesData: const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    blendOnColors: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    cardRadius: 12.0,
    dialogRadius: 12.0,
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
    color: Color(0xff080808),
    surfaceTintColor: Colors.transparent,
  ),
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xff080808)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xff080808)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xff116383).withOpacity(.40)),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xff080808),
    disabledColor: const Color(0xff080808).withOpacity(0.4),
    labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: const Color(0xff116383).withOpacity(0.3), width: 1),
    ),
  ),
  cardTheme: const CardThemeData(color: Color(0xff080808)),
  dialogTheme: const DialogThemeData(backgroundColor: Color(0xff080808)),
  listTileTheme: const ListTileThemeData(),
  drawerTheme: const DrawerThemeData(),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: ThemeHelpers.primaryBlue,
    refreshBackgroundColor: Color(0xff000000),
  ),
  appBarTheme: const AppBarTheme(backgroundColor: Color(0xff000000)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xff000000),
    unselectedItemColor: Colors.white,
  ),
  canvasColor: const Color(0xff080808),
  dividerColor: const Color(0xff116383),
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
    ),
  ),
);
