import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/providers/logo_provider.dart';

/// A base class that is used to render a logo based on the given class data
abstract class LogoBaseWidget<T> extends ConsumerWidget {
  final T logoClass;
  final double height;
  final double width;

  const LogoBaseWidget(this.logoClass, {super.key, this.height = 24, this.width = 24});

  ({String? faviconImageUrl, String? fullImageUrl}) getLogoUrl(BuildContext context);
  IconData getFallbackIcon(BuildContext context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urls = getLogoUrl(context);
    final imageAsync = ref.watch(logoImageProvider(faviconUrl: urls.faviconImageUrl, fullUrl: urls.fullImageUrl));

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        width: width,
        height: height,
        child: imageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          error: (_, __) => Icon(getFallbackIcon(context), size: height * 0.75),
          data: (bytes) => Image.memory(
            bytes,
            fit: BoxFit.cover,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (context, _, __) => Icon(getFallbackIcon(context), size: height * 0.75),
          ),
        ),
      ),
    );
  }
}
