import 'package:flutter/material.dart';
import 'package:sprout/core/widgets/card.dart';

/// Re-usable component that wraps all our setup pages
class SetupPageWrapper extends StatelessWidget {
  final bool isDesktop;
  final Widget child;

  final String nextBtnText;
  final VoidCallback? nextBtnAction;
  final bool nextBtnIsLoading;

  const SetupPageWrapper(
    this.isDesktop,
    this.nextBtnText,
    this.nextBtnAction,
    this.child, {
    super.key,
    this.nextBtnIsLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SproutCard(
          child: Padding(
            padding: EdgeInsetsGeometry.all(24),
            child: Column(
              spacing: 24,
              children: [
                child,
                // Next button
                SizedBox(
                  width: 360,
                  child: FilledButton(
                    onPressed: nextBtnAction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        if (nextBtnIsLoading) const SizedBox(height: 24, width: 24, child: CircularProgressIndicator()),
                        Text(nextBtnText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
