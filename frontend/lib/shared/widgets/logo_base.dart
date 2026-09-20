import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// A base class that is used to render a logo based on the given class data.
abstract class LogoBaseWidget<T> extends ConsumerWidget {
  final T logoClass;
  final double size;
  final Color? backgroundColor;

  /// Creates a [LogoBaseWidget] instance.
  const LogoBaseWidget(
    this.logoClass, {
    super.key,
    this.size = 24,
    this.backgroundColor,
  });

  /// Returns the watchable provider instance for the specific model type.
  ProviderListenable<AsyncValue<List<String>>> getProvider(BuildContext context, T data, double size);

  /// Returns the icon to display if the image fails to load.
  Icon getFallbackIcon(BuildContext context) {
    return Icon(Icons.account_balance, size: size);
  }

  /// Returns the background color for the container.
  Color? getBackgroundColor(BuildContext context) => backgroundColor;

  Widget _buildImage(BuildContext context, List<String> urls, int index) {
    // Fallback to default icon
    if (index >= urls.length) return getFallbackIcon(context);

    return Image.network(
      urls[index],
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => _buildImage(context, urls, index + 1),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageAsync = ref.watch(getProvider(context, logoClass, size));
    final dynamicRadius = size * 0.2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getBackgroundColor(context),
        borderRadius: BorderRadius.circular(dynamicRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dynamicRadius),
        child: imageAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
          error: (_, __) => Center(child: getFallbackIcon(context)),
          data: (urls) => urls.isEmpty ? Center(child: getFallbackIcon(context)) : _buildImage(context, urls, 0),
        ),
      ),
    );
  }
}
