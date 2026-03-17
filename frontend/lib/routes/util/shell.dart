import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/app_bar.dart';
import 'package:sprout/routes/util/bottom_nav.dart';
import 'package:sprout/routes/util/sidenav.dart';
import 'package:sprout/shared/widgets/lifecycle_observer.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/shared/widgets/lock.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A lightweight wrapper that provides persistent navigation (e.g., Side/Bottom Nav).
class SproutShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState? state;

  const SproutShell({super.key, required this.child, this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userConfigAsync = ref.watch(userConfigProvider);
    final bioState = ref.watch(biometricsProvider);
    final theme = Theme.of(context);
    // Determine layout based on screen size
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (authState.isLoading || (!userConfigAsync.hasValue && userConfigAsync.isLoading)) {
      return const SproutLoadingIndicator(key: ValueKey('sprout_lock_screen'));
    }

    final secureModeEnabled = userConfigAsync.value?.secureMode ?? false;
    final needsBioCheck = !kIsWeb && secureModeEnabled && authState.value != null;

    // If we need a check and the bioState hasn't flipped to 'unlocked' yet
    if (needsBioCheck && bioState.isLocked) {
      return const SproutLockWidget(key: ValueKey('sprout_locked_screen'));
    }

    return SproutLifecycleObserver(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: theme.bottomNavigationBarTheme.backgroundColor,
          systemNavigationBarIconBrightness: theme.bottomNavigationBarTheme.unselectedItemColor == Colors.white
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Scaffold(
          appBar: const SproutAppBar(),
          body: Row(
            children: [
              if (isDesktop) SproutSideNav(),
              Expanded(child: child),
            ],
          ),
          bottomNavigationBar: isDesktop || state == null ? null : SproutBottomNav(currentPath: state!.fullPath ?? ""),
        ),
      ),
    );
  }
}
