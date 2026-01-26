import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/config/provider.dart';
import 'package:sprout/core/client/extended_api_client.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/user/user_provider.dart';

/// Renders a field that allows setting the current setup connection
class ConnectionSetupField extends StatefulWidget {
  final VoidCallback? onURLSet;
  final double? minButtonSize;
  final bool disabled;

  const ConnectionSetupField({super.key, this.onURLSet, this.minButtonSize, this.disabled = false});

  /// Sets the connection url to the given value and re-attempts a connection
  static Future<void> setUrl(String? url) async {
    final configProvider = ServiceLocator.get<ConfigProvider>();
    ConfigProvider.connectionUrl = url;
    await SecureStorageProvider.saveValue(SecureStorageProvider.connectionUrlKey, url);
    if (url != null) (defaultApiClient as ExtendedApiClient).basePath = "$url/api";
    // Tell the configProvider to re-attempt a connection
    await configProvider.populateUnsecureConfig();
  }

  @override
  State<ConnectionSetupField> createState() => _ConnectionSetupState();
}

class _ConnectionSetupState extends State<ConnectionSetupField> {
  final TextEditingController _connectionUrlController = TextEditingController();
  String _message = '';
  bool _isAttemptingConnection = false;

  @override
  void initState() {
    super.initState();
    _connectionUrlController.text = defaultApiClient.basePath.replaceAll("/api", "");
  }

  @override
  void dispose() {
    _connectionUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveConnectionUrl() async {
    setState(() {
      _message = '';
      _isAttemptingConnection = true;
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
    } finally {
      setState(() {
        _isAttemptingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConfigProvider, UserProvider>(
      builder: (context, provider, userProvider, child) {
        return Column(
          spacing: widget.disabled ? 0 : 12,
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
              FilledButton(
                onPressed: _isAttemptingConnection ? null : _saveConnectionUrl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    if (_isAttemptingConnection) SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                    Icon(Icons.send),
                    Text("Connect"),
                  ],
                ),
              ),
            // Error messages for the input
            if (_message != "")
              Text(
                _message,
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
