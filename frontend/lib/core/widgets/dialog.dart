import 'package:flutter/material.dart';
import 'package:sprout/core/theme.dart';
import 'package:sprout/core/widgets/button.dart';
import 'package:sprout/core/widgets/scroll.dart';

/// A reusable widget for displaying dialogs in Sprout
class SproutDialogWidget extends StatelessWidget {
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

  const SproutDialogWidget(
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
        titlePadding: EdgeInsets.symmetric(vertical: 12),
        contentPadding: EdgeInsets.only(bottom: 24),
        title: Center(
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Flex holder
                  Expanded(child: const SizedBox(width: 1)),
                  Text(dialogTitleText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
                  // Close button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ButtonWidget(
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(0.0),
                            shadowColor: WidgetStateProperty.all(Colors.transparent),
                          ),
                          color: Colors.transparent,
                          icon: Icons.close,
                          minSize: 24,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
          child: SproutScrollView(
            child: Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 8), child: child),
          ),
        ),
        actions: showSubmitButton || showCloseDialogButton
            ? [
                Row(
                  spacing: 12,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showCloseDialogButton)
                      Expanded(
                        child: FilledButton(
                          style: closeButtonStyle == null
                              ? AppTheme.errorButton
                              : closeButtonStyle!.merge(AppTheme.errorButton),
                          onPressed: !allowCloseClick
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
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
              ]
            : null,
      ),
    );
  }
}
