import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/setup/connection.dart';

class FailToConnectWidget extends StatelessWidget {
  /// Called when the connection URL reset button is clicked.
  final VoidCallback? onConnectionReset;

  const FailToConnectWidget({super.key, this.onConnectionReset});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
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
                TextWidget(
                  referenceSize: 1.5,
                  text: "Failed to connect to the backend. Please ensure the backend is running and accessible.",
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),

                if (!kIsWeb)
                  Padding(
                    padding: EdgeInsetsGeometry.directional(top: 24),
                    child: SproutTooltip(
                      message: "Resets the connection URL so you can specify a different server",
                      child: ButtonWidget(
                        text: "Reset connection",
                        minSize: screenWidth / 2,
                        onPressed: () async {
                          await ConnectionSetupField.setUrl(null);
                          // Try to reconnect
                          await configProvider.populateUnsecureConfig();
                          if (onConnectionReset != null) onConnectionReset!();
                        },
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
