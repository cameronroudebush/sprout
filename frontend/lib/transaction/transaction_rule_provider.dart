import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/dialog/base_dialog.dart';
import 'package:sprout/shared/providers/sse_provider.dart';
import 'package:sprout/transaction/dialog/rule_manual.dart';
import 'package:sprout/transaction/models/transaction_rule_state.dart';
import 'package:sprout/transaction/transaction_provider.dart';

part 'transaction_rule_provider.g.dart';

/// State for the authenticated API
@Riverpod(keepAlive: true)
Future<TransactionRuleApi> transactionRuleApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return TransactionRuleApi(client);
}

@Riverpod(keepAlive: true)
class TransactionRules extends _$TransactionRules {
  @override
  Future<TransactionRuleState> build() async {
    ref.listen(sseProvider, (prev, next) {
      final event = next.latestData?.event;
      if (event == SSEDataEventEnum.forceUpdate) {
        ref.invalidateSelf();
      }
    });

    final api = await ref.watch(transactionRuleApiProvider.future);
    final rules = await api.transactionRuleControllerGet() ?? [];

    return TransactionRuleState(rules: rules);
  }

  /// Adds a new rule and updates the local state list.
  Future<TransactionRule?> add(TransactionRule rule) async {
    _setRunning(true);
    final api = await ref.read(transactionRuleApiProvider.future);
    final addedRule = await api.transactionRuleControllerCreate(rule);

    if (addedRule != null && state.value != null) {
      final newList = [...state.value!.rules, addedRule];
      state = AsyncData(state.value!.copyWith(rules: newList, isRunning: false));
    } else {
      _setRunning(false);
    }
    return addedRule;
  }

  /// Deletes a rule from the backend and the local state.
  Future<void> delete(TransactionRule rule) async {
    _setRunning(true);
    final api = await ref.read(transactionRuleApiProvider.future);
    await api.transactionRuleControllerDelete(rule.id);

    if (state.value != null) {
      final newList = state.value!.rules.where((r) => r.id != rule.id).toList();
      state = AsyncData(state.value!.copyWith(rules: newList, isRunning: false));
    }
  }

  /// Edits an existing rule and updates it in the local list.
  Future<TransactionRule?> edit(TransactionRule rule) async {
    _setRunning(true);
    final api = await ref.read(transactionRuleApiProvider.future);
    final updatedRule = await api.transactionRuleControllerEdit(rule.id, rule);

    if (updatedRule != null && state.value != null) {
      final newList = [...state.value!.rules];
      final index = newList.indexWhere((r) => r.id == updatedRule.id);
      if (index != -1) {
        newList[index] = updatedRule;
      }
      state = AsyncData(state.value!.copyWith(rules: newList, isRunning: false));
    } else {
      _setRunning(false);
    }
    return updatedRule;
  }

  /// Triggers the backend to apply transaction rules to existing transactions.
  Future<void> manualRefresh({bool force = false}) async {
    _setRunning(true);
    final api = await ref.read(transactionRuleApiProvider.future);
    await api.transactionRuleControllerApplyRules(force: force);
    _setRunning(false);

    // After rules are applied, transactions likely changed.
    // Invalidate the transaction list to show the new categories/data.
    ref.invalidate(transactionsProvider);
  }

  /// Helper to toggle the [isRunning] state for UI feedback.
  void _setRunning(bool running) {
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(isRunning: running));
    }
  }

  /// Opens the manual refresh dialog.
  void openManualRefreshDialog(BuildContext context) {
    showSproutPopup(context: context, builder: (_) => const TransactionRuleManualDialog());
  }
}
