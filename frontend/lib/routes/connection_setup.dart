import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/config/config_provider.dart';

/// This page allows a user to adjust their connection information for Sprout. Only available on mobile.
class ConnectionSetupPage extends ConsumerStatefulWidget {
  const ConnectionSetupPage({super.key});

  @override
  ConsumerState<ConnectionSetupPage> createState() => _ConnectionSetupPageState();
}

class _ConnectionSetupPageState extends ConsumerState<ConnectionSetupPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isConnecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(connectionUrlProvider).value;
    _controller.text = currentUrl ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      final url = _controller.text.trim();
      await ref.read(unsecureConfigProvider.notifier).setConnectionUrl(url);
    } catch (e) {
      setState(() => _error = "Could not reach server. Verify the URL and try again.");
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Branding
                    Image.asset('assets/icon/color.png', height: 80, fit: BoxFit.contain),
                    const SizedBox(height: 12),
                    Text(
                      'Server Configuration',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'As a self-hosted platform, Sprout needs to know where your private instance is located. '
                      'Enter your server address below to sync your data. You can update this at any time.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // URL Input Field
                    TextFormField(
                      controller: _controller,
                      enabled: !_isConnecting,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.go,
                      onFieldSubmitted: (_) => _handleConnect(),
                      decoration: InputDecoration(
                        labelText: 'Server Address',
                        hintText: 'https://sprout.example.com',
                        helperText: "Note: Do not include '/api' at the end.",
                        prefixIcon: const Icon(Icons.link),
                        errorText: _error,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'URL is required';
                        if (!value.startsWith('http')) return 'Must start with http:// or https://';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isConnecting ? null : _handleConnect,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _isConnecting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                              )
                            : const Text('Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 32),
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
