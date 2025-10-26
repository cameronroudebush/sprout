import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// Class that renders a dropdown allowing for selection of account sub types
class AccountSubTypeSelect extends StatelessWidget {
  final Account account;
  // Callback to notify the parent widget of a change
  final void Function(AccountSubTypeEnum? newSubType)? onChanged;

  const AccountSubTypeSelect(this.account, {super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Define which subtypes belong to which account type.
    const Map<AccountTypeEnum, List<AccountSubTypeEnum>> typeToSubTypeMap = {
      AccountTypeEnum.depository: [AccountSubTypeEnum.savings, AccountSubTypeEnum.checking, AccountSubTypeEnum.HYSA],
      AccountTypeEnum.investment: [
        AccountSubTypeEnum.n401k,
        AccountSubTypeEnum.brokerage,
        AccountSubTypeEnum.IRA,
        AccountSubTypeEnum.HSA,
      ],
      AccountTypeEnum.loan: [
        AccountSubTypeEnum.student,
        AccountSubTypeEnum.mortgage,
        AccountSubTypeEnum.personal,
        AccountSubTypeEnum.auto,
      ],
      AccountTypeEnum.credit: [AccountSubTypeEnum.travel, AccountSubTypeEnum.cashBack],
      AccountTypeEnum.crypto: [AccountSubTypeEnum.wallet, AccountSubTypeEnum.staking],
    };

    final items = typeToSubTypeMap[account.type] ?? [];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<AccountSubTypeEnum>(
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
      decoration: const InputDecoration(
        labelText: "Sub-Type",
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      value: account.subType,
      hint: const Text("Sub-Type"),
      items: items.map((AccountSubTypeEnum value) {
        return DropdownMenuItem<AccountSubTypeEnum>(value: value, child: Text(value.value));
      }).toList(),
      onChanged: (val) {
        if (onChanged != null) {
          onChanged!(val);
        }
      },
    );
  }
}
