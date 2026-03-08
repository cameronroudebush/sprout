import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';

/// A base class that is used to render a logo based on the given class data
abstract class LogoBaseWidget<T> extends ConsumerStatefulWidget {
  final T logoClass;

  final double height;
  final double width;

  const LogoBaseWidget(this.logoClass, {super.key, this.height = 24, this.width = 24});

  /// Returns the logo URL that we wish to render
  ({String? faviconImageUrl, String? fullImageUrl}) getLogoUrl(BuildContext context);

  /// Returns the icon to render if we can't find a normal icon
  IconData getFallbackIcon(BuildContext context);

  @override
  ConsumerState<LogoBaseWidget> createState() => _LogoBaseWidgetState();
}

class _LogoBaseWidgetState extends ConsumerState<LogoBaseWidget> {
  late Future<Uint8List> _imageFuture;

  Future<Uint8List> _fetchImageWithCookies() async {
    final client = await ref.read(baseAuthenticatedClientProvider.future);

    final api = CoreApi(client);

    final request = widget.getLogoUrl(context);

    final response = await api.imageProxyControllerHandleImageProxyWithHttpInfo(
      faviconImageUrl: request.faviconImageUrl,
      fullImageUrl: request.fullImageUrl,
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImageWithCookies();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<Uint8List>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Icon(widget.getFallbackIcon(context), size: widget.height * 0.75);
            }

            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              errorBuilder: (context, url, error) {
                return Icon(widget.getFallbackIcon(context), size: widget.height * 0.75);
              },
            );
          },
        ),
      ),
    );
  }
}
