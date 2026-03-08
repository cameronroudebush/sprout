import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/notification/firebase_provider.dart';

/// An observer mechanism that handles firing functionality as the app goes to the background or comes back to foreground
class SproutLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const SproutLifecycleObserver({super.key, required this.child});

  @override
  ConsumerState<SproutLifecycleObserver> createState() => _SproutLifecycleObserverState();
}

class _SproutLifecycleObserverState extends ConsumerState<SproutLifecycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final bio = ref.read(biometricsProvider.notifier);

    switch (state) {
      case AppLifecycleState.resumed:
        // Check launch notifications and clear them as needed
        ref.read(firebaseProvider.notifier).checkLaunchNotification();
        await bio.unlockResume();
        break;

      case AppLifecycleState.paused:
        await bio.lockBackground();
        break;

      case AppLifecycleState.inactive:
        // Immediate privacy overlay for the App Switcher
        await bio.enableScreenPrivacy();
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
