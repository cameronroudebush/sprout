import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/widgets/login_bg.dart';
import 'package:sprout/auth/widgets/login_form.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/logo.dart';

/// A page that displays the login for a user to get into Sprout
class LoginPage extends ConsumerWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final config = ref.watch(unsecureConfigProvider).value;

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
                      color: Colors.black.withOpacity(0.1),
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
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
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
                        Text(
                          config?.version ?? "",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
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
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.secondary,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: SproutCard(
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
                                Text(
                                  config?.version ?? "",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
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
