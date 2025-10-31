import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/layout.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/user/widgets/login_form.dart';

/// A stateful widget for the login page.
class LoginPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginPage({super.key, this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Builds the side display for the user login
  Widget _buildForm(BuildContext context, bool isDesktop) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        final mediaQuery = MediaQuery.of(context).size;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 640 : mediaQuery.width, maxHeight: isDesktop ? 640 : 640),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Card(
              child: Padding(
                padding: EdgeInsetsGeometry.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Sprout logo
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: isDesktop ? 48 : 12),
                      child: Image.asset(
                        'assets/logo/color-transparent-no-tag.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Column(
                      spacing: 24,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Welcome text
                        Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: TextWidget(
                            referenceSize: 2,
                            text: 'Welcome Back!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Render the login form for actual input
                        LoginForm(),
                      ],
                    ),
                    // Render the app version
                    const SizedBox(height: 24),
                    Text(configProvider.unsecureConfig?.version ?? ""),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      final form = _buildForm(context, isDesktop);
      final mediaQuery = MediaQuery.of(context).size;
      return SizedBox(
        height: mediaQuery.height,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage((kIsWeb ? "" : "assets/") + (isDesktop ? 'login/login.png' : 'login/login.mobile.png')),
              fit: BoxFit.fill,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Login box
              form,
            ],
          ),
        ),
      );
    });
  }
}
