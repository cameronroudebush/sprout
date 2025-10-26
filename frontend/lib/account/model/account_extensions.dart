import 'package:sprout/api/api.dart';

/// Helper functions for account
extension AccountExtensions on Account {
  /// Returns if this account affects the net worth negativity due to being a loan type.
  get isNegativeNetWorth {
    return type == AccountTypeEnum.credit || type == AccountTypeEnum.loan;
  }
}
