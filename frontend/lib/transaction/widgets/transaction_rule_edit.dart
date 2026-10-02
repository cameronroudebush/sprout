import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/widgets/account_dropdown.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_dropdown.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_rule_provider.dart';

/// A widget that displays the editing capabilities of a [TransactionRule]
class TransactionRuleEdit extends ConsumerStatefulWidget {
  final TransactionRule? rule;

  /// Initial value for the description
  final dynamic initialValue;

  const TransactionRuleEdit(this.rule, {super.key, this.initialValue});

  @override
  ConsumerState<TransactionRuleEdit> createState() =>
      _TransactionRuleInfoState();
}

class _TransactionRuleInfoState extends ConsumerState<TransactionRuleEdit> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _priorityController = TextEditingController();
  TransactionRuleTypeEnum _type = TransactionRuleTypeEnum.description;
  String? _categoryId;
  String? _accountId;
  bool _strict = false;
  bool _enabled = true;
  bool _isSubmitting = false;

  /// Tracks whether the user has manually edited the priority field, so we
  /// don't overwrite their input once the rules provider finishes loading.
  bool _priorityEdited = false;

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
      _categoryId = rule.categoryId;
      _accountId = rule.accountId;
      _strict = rule.strict;
      _enabled = rule.enabled;
    } else {
      // Initialize for a new rule
      _valueController.text =
          widget.initialValue == null ? "" : widget.initialValue.toString();
      _priorityController.text =
          lastRuleOrder == null ? "1" : (lastRuleOrder + 1).toString();
      _type = TransactionRuleTypeEnum.description;
      _categoryId = null;
      _accountId = null;
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
      categoryId: _categoryId,
      accountId: _accountId,
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

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final isEdit = widget.rule != null;
    final notifier = ref.read(transactionRulesProvider.notifier);

    // Validate the form before proceeding with submission
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newRule = _getNewRule();
    if (!_valHasChanged(newRule)) {
      Navigator.of(context).pop();
      return;
    }

    final route = ModalRoute.of(context);
    setState(() => _isSubmitting = true);
    try {
      if (isEdit) {
        await notifier.edit(newRule);
      } else {
        await notifier.add(newRule);
      }

      if (mounted && route?.isCurrent == true) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ref.read(notificationsProvider.notifier).openWithAPIException(error);
      }
    } finally {
      if (mounted && route?.isCurrent == true) {
        setState(() => _isSubmitting = false);
      }
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
        child: const Text('Removing this transaction rule cannot be undone.',
            textAlign: TextAlign.center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.rule != null;
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();

    // The rules provider may still be loading when this dialog is opened (e.g.
    // from a transaction's details). Once it resolves, initialize the priority
    // for new rules to one greater than the highest existing order, unless the
    // user has already edited the field themselves.
    ref.listen(transactionRulesProvider, (previous, next) {
      if (isEdit || _priorityEdited) return;

      final rules = next.value?.rules;
      if (rules == null) return;

      final lastRuleOrder = rules.lastOrNull?.order;
      final priority =
          lastRuleOrder == null ? "1" : (lastRuleOrder + 1).toString();
      if (_priorityController.text != priority) {
        _priorityController.text = priority;
      }
    });

    return SproutBaseDialogWidget(
      isEdit ? "Edit Rule" : "Add Rule",
      showCloseDialogButton: !_isSubmitting,
      closeButtonText: "Cancel",
      showSubmitButton: !isDemoMode,
      submitButtonText: _isSubmitting
          ? "Saving..."
          : isEdit
              ? "Save"
              : "Add Rule",
      allowSubmitClick: !_isSubmitting,
      onSubmitClick: _submit,
      extraButtons: !isEdit || isDemoMode || _isSubmitting
          ? null
          : IconButton.filled(
              style: ThemeHelpers.errorButton,
              onPressed: () => _confirmDelete(context),
              icon: Icon(Icons.delete),
            ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Offstage(
            offstage: _isSubmitting,
            child: _getForm(isEdit, theme),
          ),
          if (_isSubmitting)
            SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    Text(isEdit ? "Saving rule..." : "Adding rule..."),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the form for display based on type and editing capability
  Widget _getForm(bool isEdit, ThemeData theme) {
    String valueHintText = "e.g., 'Starbucks' or '15.50'";
    String valueHelpText =
        "Enter the specific text or numerical value to match.";

    if (_type == TransactionRuleTypeEnum.description) {
      if (_strict) {
        valueHelpText =
            "Enter the exact text to match the transaction's description.";
        valueHintText = "e.g., 'Starbucks Coffee' for an exact match";
      } else {
        valueHelpText =
            "Enter the text you want to match partially in the transaction's description. You can use | for OR statements.";
        valueHintText = "e.g., 'Starbucks' to match 'Starbucks Coffee'";
      }
    } else if (_type == TransactionRuleTypeEnum.amount) {
      valueHelpText = "Amount rules match transactions with this exact amount.";
      valueHintText = "e.g., '25.50' to match transactions of exactly 25.50";
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
                  Text("Priority", style: theme.textTheme.titleMedium),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _priorityController,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    onFieldSubmitted: (value) => _submit(),
                    onChanged: (value) {
                      _priorityEdited = true;
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please enter a value";
                      final parsed = int.tryParse(value);
                      if (parsed == null)
                        return "This value must be an integer";
                      return null;
                    },
                  ),
                  Text(
                    "Higher numbers run first. The first matching rule assigns its category, so give more specific rules higher numbers.",
                    style: helpStyle,
                  ),
                ],
              ),
              // Rule type
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text("Rule Type", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField<TransactionRuleTypeEnum>(
                    dropdownColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    value: _type,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    items: TransactionRuleTypeEnum.values.map((type) {
                      return DropdownMenuItem(
                          value: type, child: Text(type.value));
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _type = newValue);
                      }
                    },
                    validator: (value) =>
                        value == null ? "Please select a rule type" : null,
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
                  Text("Value", style: theme.textTheme.titleMedium),
                  TextFormField(
                    keyboardType: _type == TransactionRuleTypeEnum.amount
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    controller: _valueController,
                    decoration: InputDecoration(
                        hintText: valueHintText,
                        border: const OutlineInputBorder()),
                    onFieldSubmitted: (value) => _submit(),
                    onChanged: (value) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please enter a value";
                      if (_type == TransactionRuleTypeEnum.amount) {
                        final parsed = double.tryParse(value);
                        if (parsed == null)
                          return "This value must be numerical";
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
                      Text("Category", style: theme.textTheme.titleMedium),
                      Tooltip(
                        message: "Add new category",
                        child: IconButton(
                          icon: const Icon(Icons.category),
                          onPressed: () async {
                            await showSproutPopup(
                              context: context,
                              builder: (_) => CategoryEdit(
                                null,
                                onAdd: (category) {
                                  setState(() => _categoryId = category.id);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  CategoryDropdown(_categoryId, (cat) {
                    setState(() => _categoryId = cat?.id);
                  }),
                  Text("The category applied when the rule is met.",
                      style: helpStyle),
                ],
              ),
              // Account to assign
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text("Account", style: theme.textTheme.titleMedium),
                  AccountDropdown(_accountId, (acc) {
                    setState(() => _accountId = acc?.id);
                  }),
                  Text("The account affected by this rule if selected.",
                      style: helpStyle),
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
                        Text("Strict Match",
                            style: theme.textTheme.titleMedium),
                        Text(
                            _type == TransactionRuleTypeEnum.amount
                                ? "Amount rules always match exact values; this setting applies to description rules."
                                : "Match the full description exactly instead of matching text it contains.",
                            style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(
                      value: _strict,
                      onChanged: (newValue) =>
                          setState(() => _strict = newValue)),
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
                        Text("Enabled", style: theme.textTheme.titleMedium),
                        Text("Toggle to enable or disable this rule.",
                            style: helpStyle),
                      ],
                    ),
                  ),
                  Switch(
                      value: _enabled,
                      onChanged: (newValue) =>
                          setState(() => _enabled = newValue)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
