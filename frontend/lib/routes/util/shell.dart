import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/auth/biometric_provider.dart';
import 'package:sprout/routes/util/app_bar.dart';
import 'package:sprout/routes/util/bottom_nav.dart';
import 'package:sprout/routes/util/desktop_header.dart';
import 'package:sprout/routes/util/sidenav.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/loading.dart';
import 'package:sprout/shared/widgets/lock.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A lightweight wrapper that provides persistent navigation (e.g., Side/Bottom Nav).
class SproutShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState? state;

  const SproutShell({super.key, required this.child, this.state});

  @override
  ConsumerState<SproutShell> createState() => _SproutShellState();
}

class _SproutShellState extends ConsumerState<SproutShell> {
  bool _hasPromptedLock = false;

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
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

    // Wait until loading finishes to trigger the biometric prompt
    if (isLoading) {
      _hasPromptedLock = false;
    } else if (needsBioCheck && bioState.isLocked && !_hasPromptedLock && !bioState.isUnlocking) {
      _hasPromptedLock = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(biometricsProvider.notifier).tryManualUnlock();
        }
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.bottomNavigationBarTheme.backgroundColor,
        systemNavigationBarIconBrightness:
            theme.bottomNavigationBarTheme.unselectedItemColor == Colors.white ? Brightness.light : Brightness.dark,
      ),
      child: SproutLayoutBuilder((isDesktop, context, constraints) {
        return Stack(
          children: [
            Scaffold(
              appBar: !isDesktop && !authNotifier.isSetupMode ? const SproutAppBar() : null,
              body: isDesktop
                  ? Row(
                      children: [
                        if (!authNotifier.isSetupMode) const SproutSideNav(),
                        // Desktop has a fancy little card in card design
                        Expanded(
                          child: Container(
                            color: theme.cardTheme.color ?? theme.cardColor,
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(children: [
                                  if (!authNotifier.isSetupMode) const SproutDesktopHeader(),
                                  Expanded(child: widget.child)
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : widget.child,
              bottomNavigationBar:
                  isDesktop || widget.state == null ? null : SproutBottomNav(currentPath: widget.state!.fullPath ?? ""),
            ),

            if (needsBioCheck && bioState.isLocked)
              const Positioned.fill(
                child: SproutLockWidget(key: ValueKey('sprout_locked_screen')),
              ),

            // Loading Indicator rendered on absolute top
            if (!authNotifier.isSetupMode && isLoading)
              const Positioned.fill(
                child: SproutLoadingIndicator(key: ValueKey('sprout_loading')),
              ),
          ],
        );
      }),
    );
  }
}
