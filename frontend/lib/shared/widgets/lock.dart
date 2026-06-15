import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/icon.dart';

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
    // Safely triggers the biometric prompt immediately after the layout renders
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
    final theme = Theme.of(context);
    final bioState = ref.watch(biometricsProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8)),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const SproutIcon(96),
                  ),
                  Text(
                    "Sprout is Locked",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "Biometric authentication is required to access your financial data and account balances.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
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
                    child: Text("Switch Account or Logout",
                        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.secondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
