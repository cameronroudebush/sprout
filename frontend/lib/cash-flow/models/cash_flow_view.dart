import 'package:intl/intl.dart';

enum CashFlowView { monthly, yearly }

class CashFlowViewFormatter {
  /// Returns the text to display for the name of the current period
  static String getPeriodText(CashFlowView view, DateTime selectedDate) {
    return view == CashFlowView.monthly ? DateFormat('MMMM yyyy').format(selectedDate) : selectedDate.year.toString();
  }

  /// Returns the text to display when we don't have enough data for this period
  static String getNoDataText(CashFlowView view, DateTime selectedDate) {
    final period = CashFlowViewFormatter.getPeriodText(view, selectedDate);
    return "No data for $period";
  }
}
