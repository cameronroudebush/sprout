import 'package:flutter/material.dart';
import 'package:sprout/theme/absolute_dark.dart';

/// Helper theme functions
class ThemeHelpers {
  static const Color primaryBlue = Color(0xff6b9ac4);

  static final maxDesktopSize = 1920.0;

  /// Styling for displaying error buttons
  static final errorButton = FilledButton.styleFrom(
    backgroundColor: absoluteDarkTheme.colorScheme.error,
    foregroundColor: absoluteDarkTheme.colorScheme.onError,
  );

  /// Styling for displaying primary buttons
  static final primaryButton = FilledButton.styleFrom(
    backgroundColor: absoluteDarkTheme.colorScheme.primary,
    foregroundColor: absoluteDarkTheme.colorScheme.onPrimary,
  );

  /// Styling for displaying secondary buttons
  static final secondaryButton = FilledButton.styleFrom(
    backgroundColor: absoluteDarkTheme.colorScheme.secondary,
    foregroundColor: absoluteDarkTheme.colorScheme.onSecondary,
  );
}
