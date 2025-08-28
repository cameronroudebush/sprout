import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/api/client.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/text.dart';
import 'package:sprout/setup/provider.dart';
import 'package:sprout/user/provider.dart';

/// Renders a field that allows setting the current setup connection
class ConnectionSetupField extends StatefulWidget {
  final VoidCallback? onURLSet;
  final double? minButtonSize;
  final bool disabled;

  const ConnectionSetupField({super.key, this.onURLSet, this.minButtonSize, this.disabled = false});

  /// Sets the connection url to the given value and re-attempts a connection
  static Future<void> setUrl(String? url) async {
    final configProvider = ServiceLocator.get<ConfigProvider>();
    final setupProvider = ServiceLocator.get<SetupProvider>();
    await setupProvider.api.secureStorage.saveValue(RESTClient.connectionUrlKey, url);
    await setupProvider.api.client.setBaseUrl();
    // Tell the configProvider to re-attempt a connection
    await configProvider.populateUnsecureConfig();
  }

  @override
  State<ConnectionSetupField> createState() => _ConnectionSetupState();
}

class _ConnectionSetupState extends State<ConnectionSetupField> {
  final TextEditingController _connectionUrlController = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    _connectionUrlController.text = ServiceLocator.get<ConfigProvider>().api.client.baseUrl ?? '';
  }

  @override
  void dispose() {
    _connectionUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveConnectionUrl() async {
    setState(() {
      _message = '';
    });

    final url = _connectionUrlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _message = 'Connection URL cannot be empty.';
      });
      return;
    }

    try {
      await ConnectionSetupField.setUrl(url);
      setState(() {
        _message = 'Connection URL saved successfully!';
      });
      if (widget.onURLSet != null) widget.onURLSet!();
      // Optionally, navigate or trigger a success callback
    } catch (e) {
      setState(() {
        _message = 'Failed to save connection URL: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigProvider, UserProvider>(
      builder: (context, provider, userProvider, child) {
        final currentConnectionUrl = provider.api.client.baseUrl;
        return Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Actual input
            TextField(
              controller: _connectionUrlController,
              enabled: !widget.disabled,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
                alignLabelWithHint: true,
                hintText: widget.disabled ? "" : 'eg. https://sprout.example.com',
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (String value) {
                _saveConnectionUrl();
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            // Button for saving the connection url
            if (!widget.disabled)
              ButtonWidget(
                icon: Icons.send,
                text: 'Connect',
                minSize: 400,
                onPressed: currentConnectionUrl != _connectionUrlController.text ? _saveConnectionUrl : null,
              ),
            // Error messages for the input
            TextWidget(
              text: _message,
              style: TextStyle(
                color: _message.contains('Failed') ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}
