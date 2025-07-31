/// An enum that provides the available chart ranges for the user to select
enum ChartRange { oneDay, sevenDays, oneMonth, threeMonths, sixMonths, oneYear, allTime }

/// Utility class for manipulating data with @ChartRange
class ChartRangeUtility {
  /// Given a chart range, converts it into a duration calculation
  static Duration getDurationForRange(ChartRange range) {
    switch (range) {
      case ChartRange.oneDay:
        return const Duration(days: 2);
      case ChartRange.sevenDays:
        return const Duration(days: 7);
      case ChartRange.oneMonth:
        return const Duration(days: 30);
      case ChartRange.threeMonths:
        return const Duration(days: 90);
      case ChartRange.sixMonths:
        return const Duration(days: 180);
      case ChartRange.oneYear:
      default:
        return const Duration(days: 365);
    }
  }

  /// Given a chart range and a number of spots to display, returns how many
  ///   elements should be displayed per N days for that range.
  static double getChartInterval(ChartRange range, int numberOfSpots) {
    switch (range) {
      case ChartRange.oneDay:
      case ChartRange.sevenDays:
        return 1;
      case ChartRange.oneMonth:
        return 6;
      // case ChartRange.oneYear:
      default:
        return 30;
    }
  }

  /// Given a chart range, returns the date format to use for displaying that chart data
  static String getDateFormat(ChartRange chartRange) {
    switch (chartRange) {
      case ChartRange.sevenDays:
        return 'EEE';
      case ChartRange.oneMonth:
        return 'MMM dd';
      // case ChartRange.oneYear:
      default:
        return 'MMM yy';
    }
  }

  /// If we have enough data for this chart to be curved for this range
  static bool shouldBeCurved(ChartRange chartRange) {
    switch (chartRange) {
      case ChartRange.oneDay:
      case ChartRange.sevenDays:
      case ChartRange.oneMonth:
        return false;
      default:
        return true;
    }
  }

  /// Returns the given chart range as a pretty string
  ///
  /// @useExtendedPeriodString If we should display an extended version of the string (1 month vs 1M)
  static String asPretty(ChartRange range, {bool useExtendedPeriodString = false}) {
    switch (range) {
      case ChartRange.oneDay:
        return useExtendedPeriodString ? "1 day" : "1D";
      case ChartRange.sevenDays:
        return useExtendedPeriodString ? "1 week" : "1W";
      case ChartRange.oneMonth:
        return useExtendedPeriodString ? "1 month" : "1M";
      case ChartRange.threeMonths:
        return useExtendedPeriodString ? "3 months" : "3M";
      case ChartRange.sixMonths:
        return useExtendedPeriodString ? "6 months" : "6M";
      case ChartRange.oneYear:
        return useExtendedPeriodString ? "1 year" : "1Y";
      case ChartRange.allTime:
        return useExtendedPeriodString ? "All time" : "All";
    }
  }
}
