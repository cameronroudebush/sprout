import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/auth/api.dart';
import 'package:sprout/config/provider.dart';

/// A base class that is used to render a logo based on the given class data
abstract class LogoBaseWidget<T> extends StatefulWidget {
  final T logoClass;

  const LogoBaseWidget(this.logoClass, {super.key});

  /// Returns the backend image proxy url without any query context.
  String getBackendProxy(BuildContext context) {
    final configProvider = Provider.of<ConfigProvider>(context);
    return "${configProvider.api.client.baseUrl}/api/image-proxy";
  }

  /// Returns the logo URL that we wish to render
  String getLogoUrl(BuildContext context);

  /// Returns the icon to render if we can't find a normal icon
  IconData getFallbackIcon(BuildContext context);

  @override
  State<LogoBaseWidget> createState() => _LogoBaseWidgetState();
}

class _LogoBaseWidgetState extends State<LogoBaseWidget> {
  String? _jwt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJwt();
  }

  /// Asynchronously fetches the JWT from secure storage.
  Future<void> _fetchJwt() async {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final String? fetchedJwt = await configProvider.api.secureStorage.getValue(AuthAPI.jwtKey);
    if (mounted) {
      setState(() {
        _jwt = fetchedJwt;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.getLogoUrl(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: 40,
        height: 40,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2.0))
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(widget.getFallbackIcon(context), size: 30.0);
                },
                headers: {if (_jwt != null) 'Authorization': 'Bearer $_jwt'},
              ),
      ),
    );
  }
}
