import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/auth/widgets/login_form.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// A page that displays the login for a user to get into Sprout
class LoginPage extends ConsumerWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  Widget _buildForm(BuildContext context, WidgetRef ref, bool isDesktop) {
    final config = ref.watch(unsecureConfigProvider).value;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 640, maxHeight: 640),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: SproutCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 12),
                  child: Image.asset(
                    'assets/logo/color-transparent-no-tag.png',
                    width: isDesktop ? 600 : 400,
                    fit: BoxFit.contain,
                  ),
                ),
                const Column(
                  spacing: 24,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Welcome Back!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    LoginForm(),
                  ],
                ),
                Text(config?.version ?? ""),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final form = _buildForm(context, ref, isDesktop);
      final mediaSize = MediaQuery.of(context).size;

      return SizedBox(
        height: mediaSize.height,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/${isDesktop ? 'login/login.png' : 'login/login.mobile.png'}'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(child: form),
        ),
      );
    });
  }
}
