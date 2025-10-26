import "package:sprout/api/api.dart";

/// Utility class for manipulating data with [ChartRangeEnum]
class ChartRangeUtility {
  /// Given a chart range, converts it into a duration calculation
  static Duration getDurationForRange(ChartRangeEnum range) {
    switch (range) {
      case ChartRangeEnum.oneDay:
        return const Duration(days: 2);
      case ChartRangeEnum.sevenDays:
        return const Duration(days: 7);
      case ChartRangeEnum.oneMonth:
        return const Duration(days: 30);
      case ChartRangeEnum.threeMonths:
        return const Duration(days: 90);
      case ChartRangeEnum.sixMonths:
        return const Duration(days: 180);
      case ChartRangeEnum.oneYear:
      default:
        return const Duration(days: 365);
    }
  }

  /// Given a chart range and a number of spots to display, returns how many
  ///   elements should be displayed per N days for that range.
  static double getChartInterval(ChartRangeEnum range, int numberOfSpots) {
    switch (range) {
      case ChartRangeEnum.oneDay:
      case ChartRangeEnum.sevenDays:
        return 1;
      case ChartRangeEnum.oneMonth:
        return 7;
      case ChartRangeEnum.threeMonths:
      default:
        return 30;
    }
  }

  /// Given a chart range, returns the date format to use for displaying that chart data
  static String getDateFormat(ChartRangeEnum range) {
    switch (range) {
      case ChartRangeEnum.oneDay:
      case ChartRangeEnum.sevenDays:
        return 'EEE';
      case ChartRangeEnum.oneMonth:
      case ChartRangeEnum.threeMonths:
      default:
        return 'MMM dd';
    }
  }

  /// If we have enough data for this chart to be curved for this range
  static bool shouldBeCurved(ChartRangeEnum range) {
    return false;
  }

  /// Returns the given chart range as a pretty string
  ///
  /// @useExtendedPeriodString If we should display an extended version of the string (1 month vs 1M)
  static String asPretty(ChartRangeEnum range, {bool useExtendedPeriodString = false}) {
    switch (range) {
      case ChartRangeEnum.oneDay:
        return useExtendedPeriodString ? "1 day" : "1D";
      case ChartRangeEnum.sevenDays:
        return useExtendedPeriodString ? "1 week" : "1W";
      case ChartRangeEnum.oneMonth:
        return useExtendedPeriodString ? "1 month" : "1M";
      case ChartRangeEnum.threeMonths:
        return useExtendedPeriodString ? "3 months" : "3M";
      case ChartRangeEnum.sixMonths:
        return useExtendedPeriodString ? "6 months" : "6M";
      case ChartRangeEnum.oneYear:
        return useExtendedPeriodString ? "1 year" : "1Y";
      case ChartRangeEnum.allTime:
        return useExtendedPeriodString ? "All time" : "All";
      default:
        return "";
    }
  }
}
