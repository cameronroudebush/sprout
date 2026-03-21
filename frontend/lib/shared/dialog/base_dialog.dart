import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// A reusable widget for displaying dialogs in Sprout
class SproutBaseDialogWidget extends StatelessWidget {
  final Widget? child;
  final String dialogTitleText;

  // Buttons & Actions
  final bool showCloseDialogButton;
  final String closeButtonText;
  final ButtonStyle? closeButtonStyle;

  final bool showSubmitButton;
  final String submitButtonText;
  final bool allowSubmitClick;
  final VoidCallback? onSubmitClick;
  final ButtonStyle? submitButtonStyle;

  /// Extra buttons to display on our bottom row as necessary
  final Widget? extraButtons;

  const SproutBaseDialogWidget(
    this.dialogTitleText, {
    super.key,
    this.child,
    this.showCloseDialogButton = false,
    this.closeButtonText = "Close",
    this.closeButtonStyle,
    this.showSubmitButton = false,
    this.submitButtonText = "Submit",
    this.allowSubmitClick = true,
    this.submitButtonStyle,
    this.onSubmitClick,
    this.extraButtons,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.sizeOf(context).width > SproutLayoutBuilder.desktopBreakpoint;

    return isDesktop ? _buildDesktopDialog(context, theme) : _buildMobileSheet(context, theme);
  }

  /// Responsive Header: Renders the Handle for Mobile or the Title for Desktop
  Widget _buildHeader(BuildContext context, ThemeData theme, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isMobile) ...[
          // Bottom sheet handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(color: theme.colorScheme.outlineVariant, borderRadius: BorderRadius.circular(10)),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(child: SizedBox.shrink()),
              Text(dialogTitleText, style: theme.textTheme.titleLarge),
              if (!isMobile)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ),
                ),
              if (isMobile) const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
      ],
    );
  }

  /// Builds the content to populate the
  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), child: child);
  }

  /// Builds the bottom row action buttons
  Widget _buildActions(BuildContext context) {
    if (!showSubmitButton && !showCloseDialogButton) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        spacing: 12,
        children: [
          if (extraButtons != null) extraButtons!,
          if (showCloseDialogButton)
            Expanded(
              child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(closeButtonText)),
            ),
          if (showSubmitButton)
            Expanded(
              child: FilledButton(
                style: submitButtonStyle,
                onPressed: allowSubmitClick ? onSubmitClick : null,
                child: Text(submitButtonText),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a mobile sheet based on the bottom sheet
  Widget _buildMobileSheet(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5), width: 1),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, theme, true),
            Flexible(child: _buildContent(context)),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Builds a standard desktop dialog
  Widget _buildDesktopDialog(BuildContext context, ThemeData theme) {
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.symmetric(vertical: 12),
      contentPadding: EdgeInsets.zero,
      title: _buildHeader(context, theme, false),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: _buildContent(context)),
            _buildActions(context),
          ],
        ),
      ),
    );
  }
}

/// Shows a responsive popup that adapts based on the screen size.
/// Uses a centered [Dialog] on Desktop/Web and a [ModalBottomSheet] on Mobile.
Future<T?> showSproutPopup<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  final bool isDesktop = MediaQuery.sizeOf(context).width > SproutLayoutBuilder.desktopBreakpoint;

  if (isDesktop) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.1),
      barrierDismissible: isDismissible,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Dialog(backgroundColor: Colors.transparent, elevation: 0, child: builder(context)),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.1),
    builder: (context) {
      return Stack(
        children: [
          GestureDetector(
            onTap: isDismissible ? () => Navigator.pop(context) : null,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.transparent,
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: builder(context),
            ),
          ),
        ],
      );
    },
  );
}
