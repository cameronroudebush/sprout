import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/icon.dart';

/// This widget is intended to display when the app is locked by biometrics
class SproutLockWidget extends ConsumerWidget {
  const SproutLockWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                children: [
                  // Hero Brand Element
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const SproutIcon(96),
                  ),
                  const SizedBox(height: 16),

                  // Security Text
                  Text(
                    "Sprout is Locked",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Biometric authentication is required to access your financial data and account balances.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
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
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Subtle Logout Option
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    child: Text("Switch Account or Logout", style: TextStyle(color: theme.colorScheme.secondary)),
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
