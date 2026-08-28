import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/provider/provider_provider.dart';
import 'package:sprout/provider/widgets/provider_icon.dart';
import 'package:sprout/shared/models/extensions/string_extensions.dart';

/// Direction option for laying out the icon and title in ProviderDisplay
enum ProviderDisplayDirection { horizontal, vertical }

/// A reusable widget to render a finance provider's title and/or icon while also gathering their
///   configuration from the backend to know how to render their display.
class ProviderDisplay extends ConsumerWidget {
  final ProviderTypeEnum providerType;
  final bool showIcon;
  final bool showTitle;
  final double iconSize;
  final TextStyle? style;
  final MainAxisSize mainAxisSize;
  final double spacing;
  final ProviderDisplayDirection direction;
  final CrossAxisAlignment crossAxisAlignment;

  const ProviderDisplay({
    super.key,
    required this.providerType,
    this.showIcon = true,
    this.showTitle = true,
    this.iconSize = 20,
    this.style,
    this.mainAxisSize = MainAxisSize.min,
    this.spacing = 8.0,
    this.direction = ProviderDisplayDirection.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final providers = ref.watch(providerConfigProvider).value;
    final config = providers?.firstWhereOrNull((p) => p.dbType == providerType);

    String providerName = config?.name ?? providerType.value.toTitleCase;

    final children = <Widget>[
      if (showIcon && config != null) FinanceProviderIcon(config, size: iconSize),
      if (showIcon && showTitle && config != null)
        direction == ProviderDisplayDirection.horizontal ? SizedBox(width: spacing) : SizedBox(height: spacing),
      if (showTitle)
        Text(
          providerName,
          style: style ?? theme.textTheme.bodyMedium,
          textAlign: direction == ProviderDisplayDirection.vertical ? TextAlign.center : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
    ];

    if (direction == ProviderDisplayDirection.vertical) {
      return Column(
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}
