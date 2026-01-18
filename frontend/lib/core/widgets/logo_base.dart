import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/core/provider/service.locator.dart';

/// A base class that is used to render a logo based on the given class data
abstract class LogoBaseWidget<T> extends StatefulWidget {
  final T logoClass;

  final double height;
  final double width;

  const LogoBaseWidget(this.logoClass, {super.key, this.height = 40, this.width = 40});

  /// Returns the backend image proxy url without any query context.
  String getBackendProxy() {
    return "${defaultApiClient.basePath}/image-proxy";
  }

  /// Returns the logo URL that we wish to render
  String getLogoUrl(BuildContext context);

  /// Returns the icon to render if we can't find a normal icon
  IconData getFallbackIcon(BuildContext context);

  @override
  State<LogoBaseWidget> createState() => _LogoBaseWidgetState();
}

class _LogoBaseWidgetState extends State<LogoBaseWidget> {
  final _tokenFuture = ServiceLocator.get<AuthProvider>().getHeaders();

  @override
  Widget build(BuildContext context) {
    final url = widget.getLogoUrl(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: widget.height,
        height: widget.width,
        child: FutureBuilder<Map<String, String>>(
          future: _tokenFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return Icon(widget.getFallbackIcon(context), size: 30.0);
            }

            return Image.network(
              url,
              fit: BoxFit.cover,
              headers: snapshot.data,
              errorBuilder: (context, url, error) {
                return Icon(widget.getFallbackIcon(context), size: 30.0);
              },
            );
          },
        ),
      ),
    );
  }
}
