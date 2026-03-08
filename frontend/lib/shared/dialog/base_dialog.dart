import 'package:flutter/material.dart';
import 'package:sprout/theme/helpers.dart';

/// A reusable widget for displaying dialogs in Sprout
class SproutBaseDialogWidget extends StatelessWidget {
  final Widget? child;
  final String dialogTitleText;

  /// If we should show the close dialog button on the bottom
  final bool showCloseDialogButton;
  final bool allowCloseClick;
  final String closeButtonText;
  final ButtonStyle? closeButtonStyle;

  /// If we want to show the submit button
  final bool showSubmitButton;
  final bool allowSubmitClick;
  final String submitButtonText;
  final VoidCallback? onSubmitClick;
  final ButtonStyle? submitButtonStyle;

  const SproutBaseDialogWidget(
    this.dialogTitleText, {
    super.key,
    this.child,
    this.showCloseDialogButton = false,
    this.closeButtonText = "Close",
    this.allowCloseClick = true,
    this.closeButtonStyle,
    this.showSubmitButton = false,
    this.submitButtonText = "Submit",
    this.allowSubmitClick = true,
    this.submitButtonStyle,
    this.onSubmitClick,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        insetPadding: EdgeInsets.zero,
        titlePadding: const EdgeInsets.symmetric(vertical: 12),
        contentPadding: const EdgeInsets.only(bottom: 24),
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  spacing: 48,
                  children: [
                    // Empty space to balance the close button
                    const Expanded(child: SizedBox.shrink()),
                    Text(dialogTitleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          // Using a subtle splash instead of full button styling
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 4, thickness: 4, color: theme.colorScheme.secondary),
            ],
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: mediaQuery.width > 640 ? 640 : mediaQuery.width * .9,
            maxHeight: mediaQuery.height * .75,
          ),
          child: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child),
          ),
        ),
        actions: showSubmitButton || showCloseDialogButton
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showCloseDialogButton)
                        Expanded(
                          child: FilledButton(
                            style: closeButtonStyle == null
                                ? ThemeHelpers.errorButton
                                : closeButtonStyle!.merge(ThemeHelpers.errorButton),
                            onPressed: !allowCloseClick ? null : () => Navigator.of(context).pop(),
                            child: Text(closeButtonText),
                          ),
                        ),
                      if (showSubmitButton)
                        Expanded(
                          child: FilledButton(
                            style: submitButtonStyle,
                            onPressed: !allowSubmitClick ? null : onSubmitClick,
                            child: Text(submitButtonText),
                          ),
                        ),
                    ],
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}
