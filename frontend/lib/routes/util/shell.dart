import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/routes/util/app_bar.dart';
import 'package:sprout/routes/util/bottom_nav.dart';
import 'package:sprout/routes/util/desktop_header.dart';
import 'package:sprout/routes/util/sidenav.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// A lightweight wrapper that provides persistent navigation (e.g., Side/Bottom Nav).
class SproutShell extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouterState? state;

  const SproutShell({super.key, required this.child, this.state});

  @override
  ConsumerState<SproutShell> createState() => _SproutShellState();
}

class _SproutShellState extends ConsumerState<SproutShell> {
  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.bottomNavigationBarTheme.backgroundColor,
        systemNavigationBarIconBrightness:
            theme.bottomNavigationBarTheme.unselectedItemColor == Colors.white ? Brightness.light : Brightness.dark,
      ),
      child: SproutLayoutBuilder((isDesktop, context, constraints) {
        return Scaffold(
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
        );
      }),
    );
  }
}
