import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/logo.dart';

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
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: 560,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: double.infinity,
            ),
            child: SproutCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SproutLogo(isDesktop ? 300 : 240),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              child,
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: nextBtnIsLoading ? null : nextBtnAction,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 12,
                          children: [
                            if (nextBtnIsLoading)
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            Text(
                              nextBtnText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
