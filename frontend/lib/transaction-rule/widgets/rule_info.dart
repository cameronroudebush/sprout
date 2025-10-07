import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/category/models/category.dart';
import 'package:sprout/category/provider.dart';
import 'package:sprout/category/widgets/dropdown.dart';
import 'package:sprout/category/widgets/info.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/widgets/dialog.dart';
import 'package:sprout/core/widgets/tooltip.dart';
import 'package:sprout/transaction-rule/models/transaction_rule.dart';
import 'package:sprout/transaction-rule/provider.dart';

/// A widget that displays the editing capabilities of a [TransactionRule]
class TransactionRuleInfo extends StatefulWidget {
  final TransactionRule? rule;
  final dynamic initialValue;
  const TransactionRuleInfo(this.rule, {super.key, this.initialValue});

  @override
  State<TransactionRuleInfo> createState() => _TransactionRuleInfoState();
}

class _TransactionRuleInfoState extends State<TransactionRuleInfo> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _priorityController = TextEditingController();
  TransactionRuleType _type = TransactionRuleType.description;
  Category? _category;
  bool _strict = false;
  bool _enabled = true;

  @override
  void initState() {
    final provider = ServiceLocator.get<TransactionRuleProvider>();
    final lastRuleOrder = provider.rules.lastOrNull?.order;
    super.initState();
    final rule = widget.rule;
    if (rule != null) {
      _valueController.text = rule.value;
      _priorityController.text = rule.order.toString();
      _type = rule.type;
      _category = rule.category;
      _strict = rule.strict;
      _enabled = rule.enabled;
    } else {
      // Initialize for a new rule
      _valueController.text = widget.initialValue == null ? "" : widget.initialValue.toString();
      _priorityController.text = lastRuleOrder == null ? "1" : (lastRuleOrder + 1).toString();
      _type = TransactionRuleType.description;
      _category = null;
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
    super.dispose();
  }

  /// Returns the form fields as the new rule
  TransactionRule _getNewRule() {
    return TransactionRule(
      id: widget.rule?.id ?? "",
      type: _type,
      value: _valueController.text,
      category: _category,
      strict: _strict,
      order: int.tryParse(_priorityController.text) ?? 1,
      enabled: _enabled,
      matches: 0,
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
    final provider = ServiceLocator.get<TransactionRuleProvider>();

    // Validate the form before proceeding with submission
    if (_formKey.currentState!.validate()) {
      final newRule = _getNewRule();

      if (!_valHasChanged(newRule)) {
        // Don't submit if no changes, just exit
      } else if (isEdit) {
        // Tell provider to update content
        provider.edit(newRule);
      } else {
        // Add a new rule
        provider.add(newRule);
      }

      // Close dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.rule != null;
    final newRule = _getNewRule();

    return SproutDialogWidget(
      isEdit ? "Edit Rule" : "Add Rule",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      allowSubmitClick: _valHasChanged(newRule) && (_formKey.currentState?.validate() ?? false),
      onSubmitClick: _submit,
      child: _getForm(isEdit),
    );
  }

  Widget _getForm(bool isEdit) {
    String valueHintText = "e.g., 'Starbucks' or '15.50'";
    String valueHelpText = "Enter the specific text or numerical value to match.";

    if (_type == TransactionRuleType.description) {
      if (_strict) {
        valueHelpText = "Enter the exact text to match the transaction's description.";
        valueHintText = "e.g., 'Starbucks Coffee' for an exact match";
      } else {
        valueHelpText =
            "Enter the text you want to match partially in the transaction's description. You can use | for OR statements.";
        valueHintText = "e.g., 'Starbucks' to match 'Starbucks Coffee'";
      }
    } else if (_type == TransactionRuleType.amount) {
      if (_strict) {
        valueHelpText = "Enter the exact amount to match the transaction's value.";
        valueHintText = "e.g., '25.50' for an exact match";
      } else {
        valueHelpText = "Enter a partial amount to match the transaction's value.";
        valueHintText = "e.g., '10' to match amounts like 10.50";
      }
    }

    final helpStyle = TextStyle(fontSize: 12, color: Colors.grey);

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        return Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  // Priority
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Priority", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _priorityController,
                        decoration: InputDecoration(hintText: valueHintText, border: OutlineInputBorder()),
                        onFieldSubmitted: (value) {
                          _submit();
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a value";
                          }
                          if (_type == TransactionRuleType.amount) {
                            final parsed = int.tryParse(value);
                            if (parsed == null) {
                              return "This value must be an integer";
                            }
                          }
                          return null;
                        },
                      ),
                      // Help
                      Text(
                        "What order this rule should be executed in in the event multiple rules match a transaction. If not provided, a default is added.",
                        style: helpStyle,
                      ),
                    ],
                  ),
                  // Rule type
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Rule Type", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButtonFormField<TransactionRuleType>(
                        dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
                        value: _type,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: TransactionRuleType.values.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type.name));
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _type = newValue;
                            });
                          }
                        },
                        validator: (value) => value == null ? "Please select a rule type" : null,
                      ),
                      // Help
                      Text(
                        "Choose whether the rule should apply to the transaction's description or amount.",
                        style: helpStyle,
                      ),
                    ],
                  ),

                  // Value to match on
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      const Text("Value", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextFormField(
                        keyboardType: _type == TransactionRuleType.amount
                            ? TextInputType.numberWithOptions(decimal: true)
                            : TextInputType.text,
                        controller: _valueController,
                        decoration: InputDecoration(hintText: valueHintText, border: OutlineInputBorder()),
                        onFieldSubmitted: (value) {
                          _submit();
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a value";
                          }
                          if (_type == TransactionRuleType.amount) {
                            final parsed = double.tryParse(value);
                            if (parsed == null) {
                              return "This value must be numerical";
                            }
                          }
                          return null;
                        },
                      ),
                      // Help
                      Text(valueHelpText, style: helpStyle),
                    ],
                  ),

                  // Category to assign to for the rule
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
                          // Add Category button
                          SproutTooltip(
                            message: "Opens a dialog to add a new category",
                            child: IconButton(
                              icon: const Icon(Icons.category),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => CategoryInfo(
                                    null,
                                    onAdd: (category) {
                                      setState(() {
                                        _category = category;
                                      });
                                    },
                                  ),
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      CategoryDropdown(_category, (cat) {
                        setState(() {
                          _category = cat;
                        });
                      }),
                      Text("This is the category that will be applied when the rule is met.", style: helpStyle),
                    ],
                  ),

                  // Strict matching
                  Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text("Strict Match", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Enables an exact match, rather than a partial match.", style: helpStyle),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Switch(
                          value: _strict,
                          onChanged: (newValue) {
                            setState(() {
                              _strict = newValue;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  // Enabled status
                  Row(
                    children: [
                      Expanded(
                        flex: 9,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            const Text("Enabled", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Toggle to enable or disable this rule from running.", style: helpStyle),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Switch(
                          value: _enabled,
                          onChanged: (newValue) {
                            setState(() => _enabled = newValue);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
