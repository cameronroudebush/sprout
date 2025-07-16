import 'package:intl/intl.dart';

final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date.toLocal());
}
