import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/widgets/category_edit.dart';
import 'package:sprout/config/config_provider.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/models/notification.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/notification.dart';
import 'package:sprout/theme/helpers.dart';
import 'package:sprout/transaction/transaction_provider.dart';
import 'package:sprout/transaction/widgets/transaction_details_config.dart';
import 'package:sprout/transaction/widgets/transaction_details_hero.dart';
import 'package:sprout/transaction/widgets/transaction_details_location.dart';
import 'package:sprout/transaction/widgets/transaction_rule_edit.dart';

class TransactionDetailsView extends ConsumerStatefulWidget {
  final Transaction transaction;
  final bool disableNonEditable;

  const TransactionDetailsView({
    super.key,
    required this.transaction,
    this.disableNonEditable = true,
  });

  @override
  ConsumerState<TransactionDetailsView> createState() => _TransactionDetailsViewState();
}

class _TransactionDetailsViewState extends ConsumerState<TransactionDetailsView> {
  final _formKey = GlobalKey<FormState>();
  late String _description;
  String? _categoryId;
  late DateTime _postedDate;

  @override
  void initState() {
    super.initState();
    _initFields();
  }

  @override
  void didUpdateWidget(covariant TransactionDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize state if a new transaction object is passed into the same widget instance
    if (oldWidget.transaction.id != widget.transaction.id ||
        oldWidget.transaction.description != widget.transaction.description ||
        oldWidget.transaction.categoryId != widget.transaction.categoryId ||
        oldWidget.transaction.posted != widget.transaction.posted) {
      _initFields();
    }
  }

  void _initFields() {
    final transaction = widget.transaction;
    _description = transaction.description;
    _categoryId = transaction.categoryId;
    _postedDate = transaction.posted;
  }

  Transaction _getNewTransaction() {
    return Transaction(
      id: widget.transaction.id,
      accountId: widget.transaction.accountId,
      description: _description,
      amount: widget.transaction.amount,
      categoryId: _categoryId,
      posted: _postedDate,
      pending: widget.transaction.pending,
    );
  }

  bool _valHasChanged() {
    final original = widget.transaction;
    final current = _getNewTransaction();

    return original.description != current.description ||
        original.categoryId != current.categoryId ||
        original.posted != current.posted;
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newTransaction = _getNewTransaction();

      if (_valHasChanged()) {
        await ref.read(transactionsProvider.notifier).editTransaction(newTransaction);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    showSproutPopup(
      context: context,
      builder: (ctx) => SproutBaseDialogWidget(
        'Delete Transaction',
        showCloseDialogButton: true,
        closeButtonStyle: ThemeHelpers.primaryButton,
        showSubmitButton: true,
        submitButtonText: "Delete",
        submitButtonStyle: ThemeHelpers.errorButton,
        onSubmitClick: () async {
          Navigator.of(ctx).pop();
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          await ref.read(transactionApiProvider).value?.transactionControllerDelete(widget.transaction.id);
        },
        child: Text(
          "Are you sure you want to permanently delete '${widget.transaction.description}'?\n\nThis action cannot be undone.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDemoMode = ref.watch(unsecureConfigProvider.notifier).isDemoMode();
    final isEditable = !widget.disableNonEditable && !widget.transaction.pending;
    final canSave = !isDemoMode && _valHasChanged() && (_formKey.currentState?.validate() ?? false);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Scrollable Form Details
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                if (widget.transaction.pending)
                  SproutNotificationWidget(
                    SproutNotification(
                      "This transaction is still pending and cannot be edited.",
                      theme.colorScheme.error,
                      theme.colorScheme.onError,
                      icon: Icons.hourglass_top_rounded,
                    ),
                    allowMultiLine: true,
                  ),
                TransactionHeroCard(
                  transaction: widget.transaction,
                  description: _description,
                  onDescriptionChanged: (val) => setState(() => _description = val),
                ),
                TransactionConfigCard(
                  transaction: widget.transaction,
                  categoryId: _categoryId,
                  postedDate: _postedDate,
                  isEditable: isEditable,
                  onCategoryChanged: (catId) => setState(() => _categoryId = catId),
                  onDateChanged: (date) => setState(() => _postedDate = date),
                ),
                TransactionLocationCard(transaction: widget.transaction),
              ],
            ),
          ),
          // Sticky Bottom Actions Card
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildActionsCard(isDemoMode, canSave),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(bool isDemoMode, bool canSave) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 8,
          children: [
            // Utility Actions
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: Tooltip(
                    message: "Create a rule based on this transaction description",
                    child: FilledButton(
                      onPressed: () async {
                        showSproutPopup(
                          context: context,
                          builder: (_) => TransactionRuleEdit(
                            null,
                            initialValue: _description,
                          ),
                        );
                      },
                      style: ThemeHelpers.secondaryButton,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.rule),
                          Text("Add Rule"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Tooltip(
                    message: "Add a new category to assign to transactions",
                    child: FilledButton(
                      onPressed: () async {
                        showSproutPopup(
                          context: context,
                          builder: (_) => CategoryEdit(
                            null,
                            onAdd: (c) => setState(() => _categoryId = c.id),
                          ),
                        );
                      },
                      style: ThemeHelpers.secondaryButton,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.category),
                          Text("New Category"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            // Primary Action Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed: isDemoMode ? null : () => _confirmDelete(context),
                  style: ThemeHelpers.errorButton,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.delete),
                      Text("Delete Transaction"),
                    ],
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: canSave ? _submit : null,
                  style: ThemeHelpers.primaryButton,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Icon(Icons.save),
                      Text("Save Changes"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
