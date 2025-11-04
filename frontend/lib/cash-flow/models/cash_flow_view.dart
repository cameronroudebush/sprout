import 'package:intl/intl.dart';

enum CashFlowView { monthly, yearly }

class CashFlowViewFormatter {
  /// Returns the text to display when we don't have enough data for this period
  static String getNoDataText(CashFlowView view, DateTime selectedDate) {
    final period = view == CashFlowView.monthly
        ? DateFormat('MMMM yyyy').format(selectedDate)
        : selectedDate.year.toString();
    return "No data for $period";
  }
}
