import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprout/theme/helpers.dart';

/// A lighter theme for people that light to hurt their eyes
final ThemeData blissLightTheme = FlexThemeData.light(
  fontFamily: 'RobotoCrisp',
  colors: const FlexSchemeColor(
    primary: ThemeHelpers.primaryBlue,
    primaryContainer: Color(0xffd1e4ff),
    secondary: Color(0xff116383),
    secondaryContainer: Color(0xffc2e8ff),
    tertiary: Color(0xff6b5778),
    tertiaryContainer: Color(0xfff2daff),
    error: Color(0xffba1a1a),
  ),
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
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
    color: Color(0xfff5f8fc), // Slightly darker, premium off-white surface tone
    surfaceTintColor: Colors.transparent,
  ),
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xfff5f8fc)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(const Color(0xfff5f8fc)),
      padding: WidgetStateProperty.all(EdgeInsets.zero),
    ),
  ),
  dividerTheme: DividerThemeData(color: const Color(0xff116383).withOpacity(.20)),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xfff5f8fc),
    disabledColor: const Color(0xfff5f8fc).withOpacity(0.5),
    labelStyle: const TextStyle(fontSize: 13, color: Color(0xff001d36)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: const Color(0xff116383).withOpacity(0.15), width: 1),
    ),
  ),
  cardTheme: const CardThemeData(color: Color(0xfff5f8fc)),
  dialogTheme: const DialogThemeData(backgroundColor: Color(0xfff5f8fc)),
  appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Color(0xff001d36)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: ThemeHelpers.primaryBlue,
    unselectedItemColor: Colors.black,
  ),
  canvasColor: const Color(0xfff5f8fc),
  dividerColor: const Color(0xff116383),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(color: const Color(0xff116383), borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(color: Colors.white, fontSize: 12),
    waitDuration: const Duration(milliseconds: 500),
    showDuration: const Duration(seconds: 2),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black, width: 1),
    ),
  ),
);
