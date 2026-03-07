import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprout/theme/helpers.dart';

/// Absolute dark defines an OLED theme
final ThemeData absoluteDarkTheme =
    FlexThemeData.dark(
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
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      platform: TargetPlatform.windows,
      cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
    ).copyWith(
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xff6b9ac4),
        refreshBackgroundColor: Color(0xff000000),
      ),
    );
