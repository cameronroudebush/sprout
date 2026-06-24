import 'package:flutter/material.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// Displays a standardized Sprout edit dialog for text-based configuration.
///
/// This helper manages its own [TextEditingController] and only enables
/// the "Save" button if the input has changed from [currentValue].
///
/// [onSave] is called with the trimmed input string upon clicking "Save".
void showSproutEditDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String? currentValue,
  required IconData icon,
  String? description,
  bool obscureText = false,
  required Function(String) onSave,
}) {
  final theme = Theme.of(context);
  final controller = TextEditingController(text: currentValue);
  final isChanged = ValueNotifier<bool>(false);

  Future<void> submit(BuildContext dialogContext) async {
    final newValue = controller.text.trim();
    if (newValue != (currentValue ?? "")) {
      try {
        await onSave(newValue);
        if (context.mounted) Navigator.pop(dialogContext);
      } catch (_) {}
    }
  }

  controller.addListener(() {
    isChanged.value = controller.text.trim() != (currentValue ?? "");
  });

  showSproutPopup(
    context: context,
    builder: (innerContext) => SproutBaseDialogWidget(
      title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 24,
        children: [
          if (description != null)
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          TextField(
            controller: controller,
            autofocus: true,
            obscureText: obscureText,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(innerContext),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => controller.clear(),
              ),
            ),
          ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: isChanged,
                  builder: (context, changed, _) {
                    return FilledButton(
                      onPressed: changed ? () => submit(innerContext) : null,
                      child: const Text("Save"),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
