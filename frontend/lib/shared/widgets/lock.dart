import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';

/// This widget is intended to display when the app is locked by biometrics
class SproutLockWidget extends ConsumerWidget {
  const SproutLockWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(width: 240, 'assets/icon/color.png', fit: BoxFit.contain, filterQuality: FilterQuality.high),
          SizedBox(
            width: 240,
            child: FilledButton(
              onPressed: () async {
                final success = await ref.read(biometricsProvider.notifier).tryManualUnlock();
                if (success) NavigationProvider.redirect("/");
              },
              child: Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 8, children: [Text("Unlock")]),
            ),
          ),
        ],
      ),
    );
  }
}
