/// Shared month comparisons and navigation for month-based views.
class MonthNavigation {
  static DateTime normalize(DateTime date) => DateTime(date.year, date.month);

  static DateTime currentMonth({DateTime? now}) {
    final date = now ?? DateTime.now();
    return normalize(date);
  }

  static DateTime addMonths(DateTime month, int offset) =>
      DateTime(month.year, month.month + offset);

  static int differenceInMonths(DateTime from, DateTime to) =>
      (to.year - from.year) * 12 + to.month - from.month;

  static bool isSameMonth(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month;

  static bool isAfter(DateTime month, DateTime limit) =>
      differenceInMonths(limit, month) > 0;

  static bool canAdvance(DateTime month, {DateTime? maxMonth}) =>
      differenceInMonths(month, maxMonth ?? DateTime.now()) > 0;
}
