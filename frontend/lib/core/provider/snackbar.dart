import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
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

  /// Clears all open snackbar's
  static void clearSnackBars() {
    ServiceLocator.scaffoldMessengerKey.currentState?.clearSnackBars();
  }

  /// Given an error, attempts to determine a error message
  ///   from it if it's an openAPI exception by parsing the JSON. If it's
  ///   not, it just toString's the error and returns it.
  static String parseOpenAPIException(dynamic e) {
    String message;
    if (e is ApiException && e.message != null) {
      try {
        final decoded = json.decode(e.message!);
        message = decoded['message'] ?? e.message;
      } catch (_) {
        message = e.message!;
      }
    } else {
      message = e.toString();
    }
    return message;
  }

  /// Opens a snackbar with an APIException. If it's not an APIException, we just treat it like a normal error.
  static void openWithAPIException(dynamic e) {
    final message = parseOpenAPIException(e);
    SnackbarProvider.openSnackbar(message, type: SnackbarType.error);
  }
}
