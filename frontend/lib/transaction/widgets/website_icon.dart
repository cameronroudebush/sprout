import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/shared/providers/logo_provider.dart';

/// Generic widget that allows displaying an icon for a website URL
class WebsiteIconWidget extends ConsumerWidget {
  final String websiteUrl;
  final double size;
  final double borderRadius;

  const WebsiteIconWidget({
    super.key,
    required this.websiteUrl,
    this.size = 20.0,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconsAsync = ref.watch(websiteIconProvider(websiteUrl, size));

    return iconsAsync.when(
      data: (urls) {
        if (urls.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(
              urls.first,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => Icon(Icons.language, size: size),
            ),
          );
        }
        return Icon(Icons.language, size: size);
      },
      loading: () => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => Icon(Icons.language, size: size),
    );
  }
}
