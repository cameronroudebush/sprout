import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';

/// This widget renders a dropdown that allows selecting the sub types based on the account type
class AccountSubTypeSelect extends StatelessWidget {
  /// The account to base on
  final Account account;

  /// What to do when the type changes
  final void Function(AccountSubTypeEnum? newSubType)? onChanged;

  const AccountSubTypeSelect(this.account, {super.key, this.onChanged});

  /// Maps a sub-type to a relevant icon for better visual recognition
  IconData _getIconForSubType(AccountSubTypeEnum? subType) {
    switch (subType) {
      case AccountSubTypeEnum.checking:
        return Icons.account_balance_wallet_outlined;
      case AccountSubTypeEnum.savings:
        return Icons.savings_outlined;
      case AccountSubTypeEnum.HYSA:
        return Icons.trending_up;
      case AccountSubTypeEnum.brokerage:
        return Icons.show_chart;
      case AccountSubTypeEnum.n401k:
      case AccountSubTypeEnum.IRA:
        return Icons.pie_chart_outline;
      case AccountSubTypeEnum.HSA:
        return Icons.medical_services_outlined;
      case AccountSubTypeEnum.mortgage:
        return Icons.home_outlined;
      case AccountSubTypeEnum.auto:
        return Icons.directions_car_outlined;
      case AccountSubTypeEnum.student:
        return Icons.school_outlined;
      case AccountSubTypeEnum.personal:
        return Icons.person_outline;
      case AccountSubTypeEnum.wallet:
        return Icons.currency_bitcoin;
      case AccountSubTypeEnum.house:
        return Icons.house;
      default:
        return Icons.account_tree_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      AccountTypeEnum.asset: [
        AccountSubTypeEnum.house,
      ],
      AccountTypeEnum.credit: [AccountSubTypeEnum.travel, AccountSubTypeEnum.cashBack],
      AccountTypeEnum.crypto: [AccountSubTypeEnum.wallet, AccountSubTypeEnum.staking],
    };

    final List<AccountSubTypeEnum> items = [...typeToSubTypeMap[account.type] ?? []];
    items.add(AccountSubTypeEnum.other); // Everyone gets other as an option
    if (items.isEmpty) return const SizedBox.shrink();

    return DropdownButtonFormField<AccountSubTypeEnum>(
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
      decoration: InputDecoration(
        prefixIcon: Icon(_getIconForSubType(account.subType), size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      value: account.subType,
      items: items.map((AccountSubTypeEnum value) {
        return DropdownMenuItem<AccountSubTypeEnum>(
          value: value,
          child: Row(mainAxisSize: MainAxisSize.min, children: [Text(value.value)]),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
