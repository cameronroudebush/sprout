import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/centered_layout.dart';

/// This widget is intended to display when the app is locked by biometrics
class SproutLockWidget extends ConsumerStatefulWidget {
  const SproutLockWidget({super.key});

  @override
  ConsumerState<SproutLockWidget> createState() => _SproutLockWidgetState();
}

class _SproutLockWidgetState extends ConsumerState<SproutLockWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleUnlock());
  }

  Future<void> _handleUnlock() async {
    final bioState = ref.read(biometricsProvider);
    if (bioState.isUnlocking) return;
    final success = await ref.read(biometricsProvider.notifier).tryManualUnlock();
    if (success && mounted) {
      NavigationProvider.redirect("/");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(biometricsProvider);

    return SproutCenteredLayout(
      title: "Sprout is Locked",
      description: "Biometric authentication is required to access your financial data and account balances.",
      actions: Column(
        spacing: 8,
        children: [
          SizedBox(
            width: 240,
            height: 48,
            child: FilledButton.icon(
              onPressed: bioState.isUnlocking
                  ? null
                  : () async {
                      final success = await ref.read(biometricsProvider.notifier).tryManualUnlock();
                      if (success) NavigationProvider.redirect("/");
                    },
              icon: bioState.isUnlocking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.fingerprint),
              label: Text(bioState.isUnlocking ? "Verifying..." : "Unlock Sprout"),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            child: Text(
              "Switch Account or Logout",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
