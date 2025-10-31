import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/setup/widgets/connection.dart';

class FailToConnectWidget extends StatefulWidget {
  const FailToConnectWidget({super.key});

  @override
  State<FailToConnectWidget> createState() => _FailToConnectWidgetState();
}

class _FailToConnectWidgetState extends State<FailToConnectWidget> {
  bool _isAttemptingConnection = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        return Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage('assets/logo/color-transparent-no-tag.png'),
                  width: MediaQuery.of(context).size.height * .6,
                ),
                SizedBox(height: 12),
                Text(
                  "Failed to connect to the backend. Please ensure the backend is running and accessible.",
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 20),
                  textAlign: TextAlign.center,
                ),

                if (!kIsWeb)
                  Padding(
                    padding: EdgeInsetsGeometry.directional(top: 24),
                    child: SproutTooltip(
                      message: "Resets the connection URL so you can specify a different server",
                      child: FilledButton(
                        onPressed: _isAttemptingConnection
                            ? null
                            : () async {
                                setState(() {
                                  _isAttemptingConnection = true;
                                });
                                await ConnectionSetupField.setUrl(null);
                                setState(() {
                                  _isAttemptingConnection = false;
                                });
                                // Try to go to home again
                                SproutNavigator.redirect("home");
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            if (_isAttemptingConnection)
                              SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                            Text("Reset connection"),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
