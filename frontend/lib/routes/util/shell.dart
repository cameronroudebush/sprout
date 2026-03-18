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
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/lifecycle_observer.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/shared/widgets/lock.dart';
import 'package:sprout/theme/helpers.dart';
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

    // Various config
    final secureModeEnabled = userConfigAsync.value?.secureMode ?? false;
    final isLoggedIn = authState.value != null;
    final needsBioCheck = !kIsWeb && secureModeEnabled && isLoggedIn;
    final isLoading =
        authState.isLoading || (!userConfigAsync.hasValue && userConfigAsync.isLoading) || !bioState.hasInitialized;

    if (isLoading) return const SproutLoadingIndicator(key: ValueKey('sprout_loading'));

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
        child: SproutLayoutBuilder((isDesktop, context, constraints) {
          return Scaffold(
            appBar: !isDesktop ? const SproutAppBar() : null,
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: ThemeHelpers.maxDesktopSize),
                child: isDesktop
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SproutSideNav(),
                          SizedBox(width: ThemeHelpers.maxWidth, child: child),
                          const SizedBox.shrink(),
                        ],
                      )
                    : child,
              ),
            ),
            bottomNavigationBar: isDesktop || state == null
                ? null
                : SproutBottomNav(currentPath: state!.fullPath ?? ""),
          );
        }),
      ),
    );
  }
}
