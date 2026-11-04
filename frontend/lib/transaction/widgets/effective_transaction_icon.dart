import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/account/widgets/account_icon.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/transaction/widgets/website_icon.dart';

/// Resolved icon source used by transaction displays and native widgets.
class TransactionIconSource {
  final Account? account;
  final String? websiteUrl;
  final Category? category;

  const TransactionIconSource({
    this.account,
    this.websiteUrl,
    this.category,
  });

  IconData get fallbackIcon => account != null
      ? Icons.account_balance
      : websiteUrl != null
          ? Icons.language
          : CategoryIcon.iconLibrary[category?.icon] ??
              Icons.question_mark_rounded;

  /// Builds the selected icon for transaction displays.
  Widget buildWidget({
    double size = 32,
    Widget? override,
  }) {
    if (account != null) return AccountIcon(account!, size: size);
    if (websiteUrl != null) return WebsiteIconWidget(websiteUrl!, size: size);
    return override ?? CategoryIcon(category, avatarSize: size / 2);
  }
}

/// Returns icon source for [transaction], prioritizing investment/crypto
/// accounts, then website icons, then category icons.
TransactionIconSource getTransactionIconSource(
  Transaction transaction, {
  Account? account,
  Category? category,
}) {
  final iconAccount = account != null &&
          (account.type == AccountTypeEnum.crypto ||
              account.type == AccountTypeEnum.investment)
      ? account
      : null;
  final websiteUrl = transaction.extra?.website;

  return TransactionIconSource(
    account: iconAccount,
    websiteUrl:
        iconAccount == null && websiteUrl != null && websiteUrl.isNotEmpty
            ? websiteUrl
            : null,
    category: category,
  );
}

/// Displays a transaction's effective account, website, or category icon.
class EffectiveTransactionIcon extends ConsumerWidget {
  final Transaction transaction;
  final double size;
  final Widget? iconOverride;

  const EffectiveTransactionIcon(
    this.transaction, {
    super.key,
    this.size = 32,
    this.iconOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(
      accountsProvider.select((asyncState) => asyncState.value?.accounts
          .firstWhereOrNull((a) => a.id == transaction.accountId)),
    );
    final category = ref.watch(
      categoriesProvider.select((asyncState) => asyncState.value
          ?.firstWhereOrNull((c) => c.id == transaction.categoryId)),
    );

    return getTransactionIconSource(
      transaction,
      account: account,
      category: category,
    ).buildWidget(size: size, override: iconOverride);
  }
}
