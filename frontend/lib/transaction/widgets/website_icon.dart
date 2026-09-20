import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/shared/providers/logo_provider.dart';
import 'package:sprout/shared/widgets/logo_base.dart';

/// Generic widget that allows displaying an icon for a website URL
class WebsiteIconWidget extends LogoBaseWidget<String> {
  /// Creates a [WebsiteIconWidget] instance.
  const WebsiteIconWidget(
    super.websiteUrl, {
    super.key,
    super.size = 20.0,
  });

  @override
  ProviderListenable<AsyncValue<List<String>>> getProvider(BuildContext context, String data, double size) {
    return websiteIconProvider(data, size);
  }

  @override
  Icon getFallbackIcon(BuildContext context) {
    return Icon(Icons.language, size: size);
  }
}
