import 'package:flutter/material.dart';
import 'package:sprout/core/provider/provider_services.dart';

class LockWidget extends StatefulWidget {
  const LockWidget({super.key});

  @override
  State<LockWidget> createState() => _LockWidgetState();
}

/// The lock cover screen to display when the app is secured by biometrics
class _LockWidgetState extends State<LockWidget> with WidgetsBindingObserver, SproutProviders {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(width: 240, 'assets/icon/color.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
          SizedBox(
            width: 240,
            child: FilledButton(
              onPressed: () => biometricProvider.tryManualUnlock(),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 8, children: [Text("Unlock")]),
            ),
          ),
        ],
      ),
    );
  }
}
