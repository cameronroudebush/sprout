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
          constraints: BoxConstraints(maxWidth: 640, maxHeight: isDesktop ? mediaQuery.height : 640),
          child: SizedBox(
            height: mediaQuery.height,
            width: isDesktop ? mediaQuery.width / 3 : mediaQuery.width,
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Card(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Sprout logo
                      Expanded(
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: isDesktop ? 48 : 12),
                          child: Image.asset(
                            'assets/logo/color-transparent-no-tag.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Column(
                        spacing: 24,
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
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text(configProvider.unsecureConfig?.version ?? "")],
                        ),
                      ),
                    ],
                  ),
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
      if (isDesktop) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/login/login.png'), fit: BoxFit.cover),
          ),
          child: Row(
            children: [
              // Login box
              form,
            ],
          ),
        );
      } else {
        return form;
      }
    });
  }
}


// Center(
//             child: Padding(
//               padding: const EdgeInsets.all(22.0),
//               child: Card(
//                 child: Padding(
//                   padding: EdgeInsetsGeometry.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Image.asset(
//                         'assets/logo/color-transparent-no-tag.png',
//                         width: MediaQuery.of(context).size.height * .4,
//                         fit: BoxFit.contain,
//                         filterQuality: FilterQuality.high,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 24),
//                         child: TextWidget(
//                           referenceSize: 2,
//                           text: !_isLoadingData ? 'Welcome Back!' : "Getting your data ready...",
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(height: 40.0),
//                       ConstrainedBox(
//                         constraints: BoxConstraints(maxWidth: 640),
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * .7,
//                           child: _isLoadingData
//                               ? Center(child: CircularProgressIndicator())
//                               : _buildLoginForm(context, configProvider),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );