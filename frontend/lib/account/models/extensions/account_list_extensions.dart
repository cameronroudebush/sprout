import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/api/api.dart';

extension AccountListExtensions on List<Account> {
  /// Sums the absolute balance for a specific account type
  double sumByType(AccountTypeEnum type) {
    return where((a) => a.type == type)
        .fold(0.0, (sum, a) => sum + a.balance.abs());
  }

  /// Calculates the total of all non-debt accounts
  double get totalAssets {
    return where((a) => AccountExtensions.groupConfig[a.type]?.isNegative == false)
        .fold(0.0, (sum, a) => sum + a.balance);
  }

  /// Calculates the total of all debt-based accounts
  double get totalDebts {
    return where((a) => AccountExtensions.groupConfig[a.type]?.isNegative == true)
        .fold(0.0, (sum, a) => sum + a.balance.abs());
  }
}