import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A reusable widget that just renders the Sprout logo
class SproutLogo extends ConsumerWidget {
  final double width;
  const SproutLogo(this.width, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final userConfig = ref.watch(userConfigProvider).value;
    final currentStyle = ref.read(userConfigProvider.notifier).getTheme(userConfig);

    final bool shouldApplyColor = currentStyle == ThemeStyleEnum.bliss;

    return SvgPicture.asset(
      'assets/logo/color-transparent-no-tag.svg',
      width: width,
      colorFilter: shouldApplyColor ? ColorFilter.mode(theme.colorScheme.secondary, BlendMode.srcIn) : null,
      fit: BoxFit.contain,
    );
  }
}
