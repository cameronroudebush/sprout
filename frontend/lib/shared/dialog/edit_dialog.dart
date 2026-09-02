import 'package:flutter/material.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';

/// Represents an individual field definition for [showSproutEditDialog].
class EditDialogField {
  final String label;
  final String? currentValue;
  final IconData icon;
  final bool obscureText;

  const EditDialogField({
    required this.label,
    this.currentValue,
    required this.icon,
    this.obscureText = false,
  });
}

/// Displays a standardized Sprout edit dialog for text-based configuration.
///
/// Supports single or multiple text fields.
///
/// [onSave] is called with the trimmed input values mapped by field index upon clicking "Save".
void showSproutEditDialog({
  required BuildContext context,
  required String title,
  String? label,
  String? currentValue,
  IconData? icon,
  bool obscureText = false,
  List<EditDialogField>? fields,
  String? description,
  required Function(List<String>) onSave,
}) {
  final theme = Theme.of(context);

  final dialogFields = fields ??
      [
        EditDialogField(
          label: label ?? "",
          currentValue: currentValue,
          icon: icon ?? Icons.edit,
          obscureText: obscureText,
        ),
      ];

  final controllers = dialogFields.map((f) => TextEditingController(text: f.currentValue)).toList();

  final initialValues = dialogFields.map((f) => f.currentValue ?? "").toList();

  final isChanged = ValueNotifier<bool>(false);

  void checkIsChanged() {
    bool hasChanged = false;
    for (int i = 0; i < controllers.length; i++) {
      if (controllers[i].text.trim() != initialValues[i]) {
        hasChanged = true;
        break;
      }
    }
    isChanged.value = hasChanged;
  }

  for (final controller in controllers) {
    controller.addListener(checkIsChanged);
  }

  Future<void> submit(BuildContext dialogContext) async {
    final newValues = controllers.map((c) => c.text.trim()).toList();
    try {
      await onSave(newValues);
      if (context.mounted) Navigator.pop(dialogContext);
    } catch (_) {}
  }

  showSproutPopup(
    context: context,
    builder: (innerContext) => SproutBaseDialogWidget(
      title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          if (description != null)
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ...List.generate(dialogFields.length, (index) {
            final field = dialogFields[index];
            final controller = controllers[index];
            return TextField(
              controller: controller,
              autofocus: index == 0,
              obscureText: field.obscureText,
              textInputAction: index == dialogFields.length - 1 ? TextInputAction.done : TextInputAction.next,
              onSubmitted: index == dialogFields.length - 1 ? (_) => submit(innerContext) : null,
              decoration: InputDecoration(
                labelText: field.label,
                prefixIcon: Icon(field.icon),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => controller.clear(),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(innerContext),
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
