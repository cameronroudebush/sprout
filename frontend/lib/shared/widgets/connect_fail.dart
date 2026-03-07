import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/tooltip.dart';

/// A widget that is used to display when we fail to connect to the backend
class ConnectionFailurePage extends ConsumerStatefulWidget {
  const ConnectionFailurePage({super.key});

  @override
  ConsumerState<ConnectionFailurePage> createState() => _ConnectionFailurePageState();
}

class _ConnectionFailurePageState extends ConsumerState<ConnectionFailurePage> {
  bool _isAttemptingConnection = false;

  Future<void> _handleReset() async {
    setState(() => _isAttemptingConnection = true);

    try {
      // Clear the stored URL
      await SecureStorageProvider.saveValue(SecureStorageProvider.connectionUrlKey, null);
      ref.invalidate(connectionUrlProvider);
      ref.invalidate(unsecureConfigProvider);
      NavigationProvider.redirect("home");
    } finally {
      if (mounted) {
        setState(() => _isAttemptingConnection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Watch the config state if we need to see if it miraculously recovers
    ref.watch(unsecureConfigProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            height: size.height * .25,
            child: SproutCard(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: const AssetImage('assets/logo/color-transparent-no-tag.png'), width: size.width * .7),
                    const SizedBox(height: 12),
                    Text(
                      "Failed to connect to the backend. Please ensure the backend is running and accessible.",
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    if (!kIsWeb)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: SproutTooltip(
                          message: "Resets the connection URL so you can specify a different server",
                          child: FilledButton(
                            onPressed: _isAttemptingConnection ? null : _handleReset,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isAttemptingConnection) ...[
                                  const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                const Text("Reset connection"),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
