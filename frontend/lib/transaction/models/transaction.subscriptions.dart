import 'package:sprout/account/models/account.dart';
import 'package:sprout/transaction/models/transaction.dart';

/// An enum to define how often a subscription is billed.
enum BillingPeriod {
  weekly,
  biWeekly,
  monthly,
  quarterly,
  semiAnnually,
  yearly,
  unknown;

  factory BillingPeriod.fromString(String value) {
    switch (value) {
      case 'weekly':
        return BillingPeriod.weekly;
      case 'bi-weekly':
        return BillingPeriod.biWeekly;
      case 'monthly':
        return BillingPeriod.monthly;
      case 'quarterly':
        return BillingPeriod.quarterly;
      case 'semi-annually':
        return BillingPeriod.semiAnnually;
      case 'yearly':
        return BillingPeriod.yearly;
      default:
        return BillingPeriod.unknown;
    }
  }
}

/// This class defines a subscription that has been determined from the transaction history
class TransactionSubscription {
  /// The description of this transaction
  final String description;

  /// The amount of this transaction
  final double amount;

  /// The number of these transactions we have counted
  final int count;

  /// How often this is billed
  final BillingPeriod period;

  /// The day this billing starts
  final DateTime startDate;

  /// The account related to the subscription
  final Account account;

  TransactionSubscription({
    required this.description,
    required this.amount,
    required this.count,
    required this.period,
    required this.startDate,
    required this.account,
  });

  factory TransactionSubscription.fromJson(Map<String, dynamic> json) {
    return TransactionSubscription(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      count: json['count'] as int,
      period: BillingPeriod.fromString(json['period'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      account: Account.fromJson(json['account']),
    );
  }

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
      case BillingPeriod.weekly:
        final diffInDays = checkDate.difference(firstDate).inDays;
        return diffInDays % 7 == 0;

      case BillingPeriod.biWeekly:
        final diffInDays = checkDate.difference(firstDate).inDays;
        return diffInDays % 14 == 0;

      case BillingPeriod.monthly:
      case BillingPeriod.quarterly:
      case BillingPeriod.semiAnnually:
      case BillingPeriod.yearly:
        // Determine the number of months in the period's step
        final int monthStep;
        switch (period) {
          case BillingPeriod.quarterly:
            monthStep = 3;
            break;
          case BillingPeriod.semiAnnually:
            monthStep = 6;
            break;
          case BillingPeriod.yearly:
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

      case BillingPeriod.unknown:
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
      category: "Subscriptions", // Hardcode category for subscriptions
      pending: false, // Subscriptions are considered posted
      account: account,
    );
  }
}
