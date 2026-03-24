import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/icon.dart';
import 'package:sprout/theme/absolute_dark.dart';

/// Reusable loading indicator to display when Sprout is still thinking
class SproutLoadingIndicator extends StatelessWidget {
  final String? message;

  const SproutLoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final indicatorSize = (size.height * 0.3).clamp(150.0, 300.0);
    final logoSize = indicatorSize * 0.5;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: indicatorSize,
              height: indicatorSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  SizedBox(
                    width: indicatorSize,
                    height: indicatorSize,
                    child: CircularProgressIndicator(
                      strokeWidth: indicatorSize * 0.04,
                      valueColor: AlwaysStoppedAnimation<Color>(absoluteDarkTheme.colorScheme.primary),
                    ),
                  ),
                  // Sprout Logo
                  Center(child: SproutIcon(logoSize)),
                ],
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 32),
              Text(
                message!,
                style: absoluteDarkTheme.textTheme.titleMedium?.copyWith(
                  color: absoluteDarkTheme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
