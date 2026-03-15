import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/routes/util/app_bar.dart';
import 'package:sprout/routes/util/bottom_nav.dart';
import 'package:sprout/routes/util/sidenav.dart';
import 'package:sprout/shared/widgets/lifecycle_observer.dart';

/// A lightweight wrapper that provides persistent navigation (e.g., Side/Bottom Nav).
class SproutShell extends ConsumerWidget {
  final Widget child;
  final GoRouterState state;

  const SproutShell({super.key, required this.child, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Determine layout based on screen size
    final isDesktop = MediaQuery.of(context).size.width > 800;

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
          bottomNavigationBar: isDesktop ? null : SproutBottomNav(currentPath: state.fullPath!),
        ),
      ),
    );
  }
}
