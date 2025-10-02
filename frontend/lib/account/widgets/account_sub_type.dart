import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/account/models/account.dart';

/// Class that renders a dropdown allowing for selection of account sub types
class AccountSubTypeSelect extends StatelessWidget {
  final Account account;
  // Callback to notify the parent widget of a change
  final void Function(String? newSubType)? onChanged;

  const AccountSubTypeSelect(this.account, {super.key, this.onChanged});

  /// Returns the string value for the account's sub type based on it's type
  static getValFromType(Account account) {
    final subType = getTypeFromVal(account.type, account.subType);
    return switch (account.type) {
      "investment" => (subType as InvestmentAccountType?)?.value,
      "loan" => (subType as LoanAccountType?)?.value,
      "credit" => (subType as CreditAccountType?)?.value,
      "depository" => (subType as DepositoryAccountType?)?.value,
      // Default case for unknown account types
      _ => null,
    };
  }

  /// Returns enumed type based on the given string
  static getTypeFromVal(String type, String? subType) {
    return switch (type) {
      "investment" => InvestmentAccountType.values.firstWhereOrNull((e) => e.value == subType),
      "loan" => LoanAccountType.values.firstWhereOrNull((e) => e.value == subType),
      "credit" => CreditAccountType.values.firstWhereOrNull((e) => e.value == subType),
      "depository" => DepositoryAccountType.values.firstWhereOrNull((e) => e.value == subType),
      // Default case for unknown account types
      _ => null,
    };
  }

  /// Updates the current account to use the new type
  void _updateAccountSubType(String? newSubTypeValue) {
    if (newSubTypeValue == null) {
      account.subType = null;
      return;
    }
    account.subType = newSubTypeValue;
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = AccountSubTypeSelect.getValFromType(account);
    final List<String> items = (switch (account.type) {
      "investment" => InvestmentAccountType.values.map((e) => e.value).toList(),
      "loan" => LoanAccountType.values.map((e) => e.value).toList(),
      "credit" => CreditAccountType.values.map((e) => e.value).toList(),
      "depository" => DepositoryAccountType.values.map((e) => e.value).toList(),
      // Default case for unknown account types
      _ => const <String>[],
    });

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: selectedValue,
      hint: const Text("Select a Sub-Type"),
      items: items.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (val) {
        _updateAccountSubType(val);
        if (onChanged != null) onChanged!(val);
      },
    );
  }
}
