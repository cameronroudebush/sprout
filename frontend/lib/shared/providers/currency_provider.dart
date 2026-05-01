import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/user/user_config_provider.dart';

part 'currency_provider.g.dart';

/// A formatter that is used to format currency content
class CurrencyFormatter {
  /// If we should be hiding our values.
  final bool privateMode;

  /// Currency code as defined by the user. All data sent to the frontend will already be in this format
  final CurrencyOptionsEnum displayCurrency;

  CurrencyFormatter({required this.privateMode, required this.displayCurrency});

  /// Given a formatted currency, returns it's actual display value, considering the private mode.
  ///   We assume the given number is already in the proper currency.
  String format(num? n, {bool compact = false, bool round = false, bool handlePrivateMode = true}) {
    if (n == null) {
      return "Unknown";
    } else {
      return _format(n, compact: compact, round: round, handlePrivateMode: handlePrivateMode);
    }
  }

  /// Formats the given number to a string, assuming the currency code is applied by the user's config to these values already.
  String _format(num amount, {bool compact = false, bool round = false, bool handlePrivateMode = true}) {
    if (handlePrivateMode && privateMode) return "***";
    double value = amount == -0.0 ? 0.0 : amount.toDouble();
    final currencyCode = displayCurrency.toString();
    if (compact) {
      return NumberFormat.compactCurrency(
        symbol: NumberFormat.simpleCurrency(name: currencyCode).currencySymbol,
        decimalDigits: 1,
      ).format(value);
    }
    final formatter = NumberFormat.simpleCurrency(
      name: currencyCode,
      decimalDigits: round ? 0 : null,
    );
    return formatter.format(round ? value.round() : value);
  }
}

/// A reusable formatter that allows you to format currencies
@riverpod
CurrencyFormatter currencyFormatter(Ref ref) {
  final config = ref.watch(userConfigProvider);
  final isPrivate = config.value?.privateMode ?? false;
  final displayCurrency = config.value?.currency ?? CurrencyOptionsEnum.USD;
  return CurrencyFormatter(privateMode: isPrivate, displayCurrency: displayCurrency);
}
