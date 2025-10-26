import 'package:sprout/api/api.dart';

/// Helper functions for Transaction Subscriptions
extension TransactionSubscriptionExtensions on TransactionSubscription {
  /// **Determines if the subscription is expected to be billed on the given [date].**
  ///
  /// This logic handles various billing periods, including the edge case for
  /// subscriptions starting on a day that doesn't exist in a subsequent month
  /// (e.g., started on Jan 31, checking for February). In that case, it will
  /// match the last day of the shorter month.
  ///
  /// Returns `true` if a billing event occurs on the specified day, otherwise `false`.
  bool isBilledOn(DateTime date) {
    // Normalize dates to midnight to ignore time-of-day components.
    final checkDate = DateTime(date.year, date.month, date.day);
    final firstDate = DateTime(startDate.year, startDate.month, startDate.day);

    // A subscription can't be billed before its start date.
    if (checkDate.isBefore(firstDate)) {
      return false;
    }

    switch (period) {
      case TransactionSubscriptionPeriodEnum.weekly:
        final diffInDays = checkDate.difference(firstDate).inDays;
        return diffInDays % 7 == 0;

      case TransactionSubscriptionPeriodEnum.biWeekly:
        final diffInDays = checkDate.difference(firstDate).inDays;
        return diffInDays % 14 == 0;

      case TransactionSubscriptionPeriodEnum.monthly:
      case TransactionSubscriptionPeriodEnum.quarterly:
      case TransactionSubscriptionPeriodEnum.semiAnnually:
      case TransactionSubscriptionPeriodEnum.yearly:
        // Determine the number of months in the period's step
        final int monthStep;
        switch (period) {
          case TransactionSubscriptionPeriodEnum.quarterly:
            monthStep = 3;
            break;
          case TransactionSubscriptionPeriodEnum.semiAnnually:
            monthStep = 6;
            break;
          case TransactionSubscriptionPeriodEnum.yearly:
            monthStep = 12;
            break;
          default: // MONTHLY
            monthStep = 1;
            break;
        }

        final monthsPassed = (checkDate.year * 12 + checkDate.month) - (firstDate.year * 12 + firstDate.month);

        // Check if the date is on a correct month interval.
        if (monthsPassed < 0 || monthsPassed % monthStep != 0) {
          return false;
        }

        // Now, check if the day of the month matches.
        // This handles cases like a start date of Jan 31 and checking Feb 28.
        final lastDayOfCheckMonth = DateTime(checkDate.year, checkDate.month + 1, 0).day;
        final expectedDay = firstDate.day > lastDayOfCheckMonth ? lastDayOfCheckMonth : firstDate.day;

        return checkDate.day == expectedDay;

      case TransactionSubscriptionPeriodEnum.unknown:
      default:
        return false;
    }
  }

  /// Converts this [TransactionSubscription] into a mock [Transaction] object.
  ///
  /// This is useful for displaying subscription information using widgets
  /// designed for [Transaction] objects, such as [TransactionRow].
  /// The `posted` date is set to the current date for display purposes.
  Transaction toMockTransaction() {
    return Transaction(
      id: description, // Use description as a unique ID for mock
      amount: -amount,
      posted: DateTime.now(),
      description: description,
      category: transaction.category, // Hardcode category
      pending: false, // Subscriptions are considered posted
      account: account,
    );
  }
}
