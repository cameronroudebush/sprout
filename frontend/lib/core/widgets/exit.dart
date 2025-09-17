import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sprout/core/provider/snackbar.dart';
import 'package:sprout/core/router.dart';

/// A widget that allows us to wrap the display so when the user uses the back button on mobile, we can allow them to exit the app.
class ExitWidget extends StatefulWidget {
  final Widget child;
  const ExitWidget({super.key, required this.child});

  @override
  State<ExitWidget> createState() => _ExitWidgetState();
}

class _ExitWidgetState extends State<ExitWidget> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // If didPop is true, it means the pop event was already handled.
        if (didPop) {
          return;
        }

        // Only apply this logic on mobile platforms (Android/iOS).
        if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
          return;
        }

        // Go back a page
        if (SproutRouter.router.canPop()) {
          SproutRouter.router.pop();
        }

        final allowExit = !SproutRouter.router.canPop();

        final now = DateTime.now();
        // Check if the time difference between presses is less than 2 seconds.
        final isSecondPress = _lastPressedAt != null && now.difference(_lastPressedAt!) < const Duration(seconds: 2);

        if (isSecondPress && allowExit) {
          // If it's the second press, exit the app
          SystemNavigator.pop();
        } else {
          // If it's the first press, update the last pressed time.
          _lastPressedAt = now;
          if (allowExit) {
            SnackbarProvider.openSnackbar("Press back again to open exit");
          }
        }
      },
      child: widget.child,
    );
  }
}
