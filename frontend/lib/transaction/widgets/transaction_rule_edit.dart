import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/account_dropdown.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/widgets/tooltip.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_rule_provider.dart';

/// A widget that displays the editing capabilities of a [TransactionRule]
class TransactionRuleEdit extends ConsumerStatefulWidget {
  final TransactionRule? rule;

  /// Initial value for the description
  final dynamic initialValue;

  const TransactionRuleEdit(this.rule, {super.key, this.initialValue});

  @override
  ConsumerState<TransactionRuleEdit> createState() => _TransactionRuleInfoState();
}

class _TransactionRuleInfoState extends ConsumerState<TransactionRuleEdit> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _priorityController = TextEditingController();
  TransactionRuleTypeEnum _type = TransactionRuleTypeEnum.description;
  Category? _category;
  Account? _account;
  bool _strict = false;
  bool _enabled = true;

  /// A style to display for our help text
  final helpStyle = TextStyle(fontSize: 12, color: Colors.grey);

  @override
  void initState() {
    super.initState();

    final rules = ref.read(transactionRulesProvider).value?.rules ?? [];
    final lastRuleOrder = rules.lastOrNull?.order;

    final rule = widget.rule;
    if (rule != null) {
      _valueController.text = rule.value;
      _priorityController.text = rule.order.toString();
      _type = rule.type;
      _category = rule.category;
      _account = rule.account;
      _strict = rule.strict;
      _enabled = rule.enabled;
    } else {
      // Initialize for a new rule
      _valueController.text = widget.initialValue == null ? "" : widget.initialValue.toString();
      _priorityController.text = lastRuleOrder == null ? "1" : (lastRuleOrder + 1).toString();
      _type = TransactionRuleTypeEnum.description;
      _category = null;
      _account = null;
      _enabled = true;
      _strict = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  /// Returns the form fields as the new rule
  TransactionRule _getNewRule() {
    return TransactionRule(
      id: widget.rule?.id ?? "",
      type: _type,
      value: _valueController.text,
      category: _category,
      account: _account,
      strict: _strict,
      order: int.tryParse(_priorityController.text) ?? 1,
      enabled: _enabled,
      matches: widget.rule?.matches ?? 0,
    );
  }

  /// Returns true if the value has changed from the original widget or not
  bool _valHasChanged(TransactionRule rule) {
    if (widget.rule == null) {
      return true;
    } else {
      final currentJson = widget.rule!.toJson();
      final newRuleJson = rule.toJson();
      return !const DeepCollectionEquality().equals(currentJson, newRuleJson);
    }
  }

  void _submit() {
    final isEdit = widget.rule != null;
    final notifier = ref.read(transactionRulesProvider.notifier);

    // Validate the form before proceeding with submission
    if (_formKey.currentState!.validate()) {
      final newRule = _getNewRule();

      if (!_valHasChanged(newRule)) {
        // Don't submit if no changes, just exit
      } else if (isEdit) {
        notifier.edit(newRule);
      } else {
        notifier.add(newRule);
      }

      // Close dialog
      Navigator.of(context).pop();
    }
  }

  /// Opens a dialog to confirm that we can delete this transaction rule
  void _confirmDelete(BuildContext context) {
    showSproutPopup(
      context: context,
      builder: (_) => SproutBaseDialogWidget(
        'Delete Rule',
        showCloseDialogButton: true,
        closeButtonText: "Cancel",
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: ThemeHelpers.errorButton,
        closeButtonStyle: ThemeHelpers.primaryButton,
        onSubmitClick: () {
          ref.read(transactionRulesProvider.notifier).delete(widget.rule!);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: const Text('Removing this transaction rule cannot be undone.', textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.rule != null;

    return SproutBaseDialogWidget(
      isEdit ? "Edit Rule" : "Add Rule",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      onSubmitClick: _submit,
      extraButtons: !isEdit
          ? null
          : IconButton.filled(
              style: ThemeHelpers.errorButton,
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete),
            ),
      child: _getForm(isEdit),
    );
  }

  /// Builds the form for display based on type and editing capability
  Widget _getForm(bool isEdit) {
    String valueHintText = "e.g., 'Starbucks' or '15.50'";
    String valueHelpText = "Enter the specific text or numerical value to match.";

    if (_type == TransactionRuleTypeEnum.description) {
      if (_strict) {
        valueHelpText = "Enter the exact text to match the transaction's description.";
        valueHintText = "e.g., 'Starbucks Coffee' for an exact match";
      } else {
        valueHelpText =
            "Enter the text you want to match partially in the transaction's description. You can use | for OR statements.";
        valueHintText = "e.g., 'Starbucks' to match 'Starbucks Coffee'";
      }
    } else if (_type == TransactionRuleTypeEnum.amount) {
      if (_strict) {
        valueHelpText = "Enter the exact amount to match the transaction's value.";
        valueHintText = "e.g., '25.50' for an exact match";
      } else {
        valueHelpText = "Enter a partial amount to match the transaction's value.";
        valueHintText = "e.g., '10' to match amounts like 10.50";
      }
    }

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              // Priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text("Priority", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _priorityController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onFieldSubmitted: (value) => _submit(),
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter a value";
                      final parsed = int.tryParse(value);
                      if (parsed == null) return "This value must be an integer";
                      return null;
                    },
                  ),
                  Text(
                    "What order this rule should be executed in in the event multiple rules match a transaction.",
                    style: helpStyle,
                  ),
                ],
              ),
              // Rule type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text("Rule Type", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<TransactionRuleTypeEnum>(
                    dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    value: _type,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: TransactionRuleTypeEnum.values.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type.value));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _type = newValue);
                      }
                    },
                    validator: (value) => value == null ? "Please select a rule type" : null,
                  ),
                  Text(
                    "Choose whether the rule should apply to the transaction's description or amount.",
                    style: helpStyle,
                  ),
                ],
              ),
              // Value to match on
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  const Text("Value", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    keyboardType: _type == TransactionRuleTypeEnum.amount
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    controller: _valueController,
                    decoration: InputDecoration(hintText: valueHintText, border: const OutlineInputBorder()),
                    onFieldSubmitted: (value) => _submit(),
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter a value";
                      if (_type == TransactionRuleTypeEnum.amount) {
                        final parsed = double.tryParse(value);
                        if (parsed == null) return "This value must be numerical";
                      }
                      return null;
                    },
                  ),
                  Text(valueHelpText, style: helpStyle),
                ],
              ),
              // Category to assign
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                      SproutTooltip(
                        message: "Add new category",
                        child: IconButton(
                          icon: const Icon(Icons.category),
                          onPressed: () async {
                            await showSproutPopup(
                              context: context,
                              builder: (_) => CategoryEdit(
                                null,
                                onAdd: (category) {
                                  setState(() => _category = category);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  CategoryDropdown(_category, (cat) {
                    setState(() => _category = cat);
                  }),
                  Text("The category applied when the rule is met.", style: helpStyle),
                ],
              ),
              // Account to assign
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  const Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
                  AccountDropdown(_account, (acc) {
                    setState(() => _account = acc);
                  }),
                  Text("The account affected by this rule if selected.", style: helpStyle),
                ],
              ),
              // Strict matching
              Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Strict Match", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Enables an exact match, rather than a partial match.", style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(value: _strict, onChanged: (newValue) => setState(() => _strict = newValue)),
                ],
              ),
              // Enabled status
              Row(
                children: [
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Enabled", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Toggle to enable or disable this rule.", style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(value: _enabled, onChanged: (newValue) => setState(() => _enabled = newValue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
