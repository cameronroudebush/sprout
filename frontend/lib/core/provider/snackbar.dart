import 'package:flutter/material.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/text.dart';

/// A class that provides static methods to open snackbar's
enum SnackbarType { info, warning, error }

class SnackbarProvider {
  /// Opens a snackbar with the given information
  static void openSnackbar(String text, {SnackbarType type = SnackbarType.info, int duration = 2}) {
    final context = ServiceLocator.scaffoldMessengerKey.currentState?.context;
    if (context != null) {
      final theme = Theme.of(context);
      Color backgroundColor;
      Color textColor;
      switch (type) {
        case SnackbarType.info:
          backgroundColor = theme.colorScheme.secondary;
          textColor = theme.colorScheme.onSecondary;
          break;
        case SnackbarType.warning:
          backgroundColor = Colors.orange;
          textColor = Colors.black;
          break;
        case SnackbarType.error:
          backgroundColor = theme.colorScheme.error;
          textColor = theme.colorScheme.onError;
          break;
      }

      ServiceLocator.scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: TextWidget(
            referenceSize: 1,
            text: text,
            style: TextStyle(color: textColor),
          ),
          duration: Duration(seconds: duration),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }
}
