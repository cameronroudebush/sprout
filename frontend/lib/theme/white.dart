import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprout/theme/helpers.dart';

/// A lighter theme for people that light to hurt their eyes
final ThemeData whiteTheme = FlexThemeData.light(
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
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  platform: TargetPlatform.windows,
  cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
);
