import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Defines themes for use in sprout
abstract final class AppTheme {
  /// How many pixels display content can max out at on desktops.
  static final maxDesktopSize = 1024.0;

  /// Styling for displaying error buttons
  static final errorButton = FilledButton.styleFrom(
    backgroundColor: dark.colorScheme.error,
    foregroundColor: dark.colorScheme.onError,
  );

  /// Styling for displaying primary buttons
  static final primaryButton = FilledButton.styleFrom(
    backgroundColor: dark.colorScheme.primary,
    foregroundColor: dark.colorScheme.onPrimary,
  );

  /// Styling for displaying primary buttons
  static final secondaryButton = FilledButton.styleFrom(
    backgroundColor: dark.colorScheme.secondary,
    foregroundColor: dark.colorScheme.secondary,
  );

  /// Dark theme design
  static final ThemeData dark =
      FlexThemeData.dark(
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
        ),
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        platform: TargetPlatform.windows,
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
      ).copyWith(
        cardTheme: const CardThemeData(color: Color(0xff191c20)),
        dialogTheme: DialogThemeData(backgroundColor: Color(0xff14171b)),
        listTileTheme: ListTileThemeData(),
        drawerTheme: DrawerThemeData(),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xff6b9ac4),
          refreshBackgroundColor: Color(0xff6b9ac4),
        ),
      );
}
