import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/notification.dart';

/// A widget that allows a user to merge a source account into a target account.
class AccountMergeDialog extends ConsumerStatefulWidget {
  /// The target account that will remain after the merge.
  final Account targetAccount;

  const AccountMergeDialog(this.targetAccount, {super.key});

  @override
  ConsumerState<AccountMergeDialog> createState() => _AccountMergeDialogState();
}

class _AccountMergeDialogState extends ConsumerState<AccountMergeDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _sourceAccountId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  /// Validates and submits the form changes
  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _sourceAccountId != null) {
      setState(() => _isSubmitting = true);

      try {
        final api = await ref.read(accountApiProvider.future);
        await api.accountControllerMergeAccounts(widget.targetAccount.id, AccountMergeDTO(sourceId: _sourceAccountId!));

        ref
            .read(notificationsProvider.notifier)
            .openFrontendOnly("Success", type: NotificationTypeEnum.success, message: "Account merged successfully");
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ref.read(notificationsProvider.notifier).openWithAPIException(e);
        // Handle error (e.g., show a snackbar)
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SproutBaseDialogWidget(
      "Merge Accounts",
      showCloseDialogButton: true,
      closeButtonText: "Cancel",
      showSubmitButton: true,
      allowSubmitClick: _sourceAccountId != null && !_isSubmitting,
      onSubmitClick: _submit,
      child: SizedBox(
        width: 500,
        child: _getForm(context, theme),
      ),
    );
  }

  /// Builds the form that allows selecting the source account and warns the user
  Widget _getForm(BuildContext context, ThemeData theme) {
    final helpStyle = const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4);

    // Watch the accounts provider to get the current list of accounts
    final allAccounts = ref.watch(accountsProvider).value?.accounts ?? [];

    // Filter accounts: Must be the same type, and cannot be the target account itself
    final validSourceAccounts = allAccounts
        .where((account) => account.id != widget.targetAccount.id && account.type == widget.targetAccount.type)
        .toList();

    // Determine a "success/keep" color based on the theme
    final keepColor = theme.brightness == Brightness.dark ? Colors.greenAccent : Colors.green.shade700;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              // Critical Warning Notification
              SproutNotificationWidget(
                SproutNotification(
                  "Warning: This action is completely irreversible. The source account will be permanently deleted.",
                  theme.colorScheme.error,
                  theme.colorScheme.onError,
                ),
                allowMultiLine: true,
              ),

              // Educational Description
              Text(
                "Merging accounts is designed for situations where your financial provider changes their internal structure, resulting in a duplicate or new account ID. "
                "This tool will move all transactions, holdings, rules, and historical data from the old account into the new one.",
                style: helpStyle,
              ),

              const Divider(),

              // Target Account Display (Read-only)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: keepColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.titleMedium,
                            children: [
                              const TextSpan(text: "Target Account "),
                              TextSpan(
                                text: "(Will Remain)",
                                style: TextStyle(color: keepColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      "This account will inherit all balances, history, transactions, and holdings.",
                      style: helpStyle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: keepColor.withValues(alpha: .5), width: 1.5),
                    ),
                    child: Text(
                      widget.targetAccount.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Source Account Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    children: [
                      Icon(Icons.delete_forever, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.titleMedium,
                            children: [
                              const TextSpan(text: "Source Account "),
                              TextSpan(
                                text: "(Will Be Deleted)",
                                style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Text(
                      "Select the old/duplicate account. Only accounts of the same type (${widget.targetAccount.type}) are shown.",
                      style: helpStyle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Select an account to migrate from",
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
                      ),
                    ),
                    initialValue: _sourceAccountId,
                    items: validSourceAccounts.map((account) {
                      return DropdownMenuItem<String>(
                        value: account.id,
                        child: Text(account.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sourceAccountId = value;
                      });
                    },
                    validator: (value) => value == null ? "Please select a source account" : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
