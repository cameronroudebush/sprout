import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/storage.dart';

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
  late Future<String?> _jwtFuture; // Store the Future itself

  @override
  void initState() {
    super.initState();
    _jwtFuture = _fetchJwt();
  }

  /// Asynchronously fetches and returns the JWT from secure storage.
  Future<String?> _fetchJwt() {
    return SecureStorageProvider.getValue(SecureStorageProvider.idToken);
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.getLogoUrl(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: widget.height,
        height: widget.width,
        child: FutureBuilder<String?>(
          future: _jwtFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return Icon(widget.getFallbackIcon(context), size: 30.0);
            }

            final jwt = snapshot.data!;
            return Image.network(
              url,
              fit: BoxFit.cover,
              headers: {'Authorization': 'Bearer $jwt'},
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
