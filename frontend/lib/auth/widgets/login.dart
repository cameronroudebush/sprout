import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' hide Badge;
import 'package:sprout/auth/widgets/login_bg.dart';
import 'package:sprout/auth/widgets/login_form.dart';
import 'package:sprout/shared/widgets/badge.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/logo.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A page that displays the login for a user to get into Sprout
class LoginPage extends ConsumerWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final packageInfo = ref.watch(packageInfoProvider).value;
    final versionInfo = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        Badge(
          label: packageInfo?.version ?? "",
          icon: Icons.web,
          variant: BadgeVariant.outline,
        ),
      ],
    );

    return Scaffold(
      body: SproutLayoutBuilder((isDesktop, context, constraints) {
        // Desktop
        if (isDesktop) {
          return Row(
            children: [
              Container(
                width: 480,
                height: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(4, 0),
                    ),
                  ],
                  border: Border(
                    right: BorderSide(
                      color: theme.colorScheme.secondary,
                      width: 4.0,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48.0, vertical: 24.0),
                    child: Column(
                      children: [
                        const Spacer(),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SproutLogo(280),
                            const SizedBox(height: 48),
                            Text(
                              'Welcome Back!',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const LoginForm(),
                          ],
                        ),
                        const Spacer(),
                        versionInfo,
                      ],
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: LoginBackgroundWidget(),
              ),
            ],
          );
        }

        // Mobile
        return Stack(
          children: [
            Positioned.fill(
              child: const LoginBackgroundWidget(
                showText: false,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: SproutCard(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: theme.colorScheme.secondary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SproutLogo(260),
                              const SizedBox(height: 32),
                              Text(
                                'Welcome Back!',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              const LoginForm(),
                              const SizedBox(height: 32),
                              versionInfo,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
