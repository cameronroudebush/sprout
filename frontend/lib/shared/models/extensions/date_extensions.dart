import 'package:intl/intl.dart';

extension DateToStringFormatterExtension on DateTime {
  /// MM/dd/yyyy
  String get toShort => DateFormat("MM/dd/yyyy").format(toLocal());

  /// MMM dd, yyyy
  String get toShortMonth => DateFormat("MMM dd, yyyy").format(toLocal());

  /// MMM dd, h:mm a
  String get toShortMonthWithTime => DateFormat("MMM dd, h:mm a").format(toLocal());

  /// Returns true if the given date is on the same day as this date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
